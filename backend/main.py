import os
import json
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import google.generativeai as genai

app = FastAPI()

# Configure Gemini API
GEMINI_API_KEY = ""
if not GEMINI_API_KEY:
    raise ValueError("GEMINI_API_KEY environment variable not set.")
genai.configure(api_key=GEMINI_API_KEY)

# Pydantic models for request and response bodies
class Message(BaseModel):
    text: str
    isFromUser: bool

class OnboardingRequest(BaseModel):
    userId: str
    message: str
    history: Optional[List[Message]] = []

class OnboardingResponse(BaseModel):
    response: str
    isDone: bool

# Define the tool for Gemini
update_user_settings_tool = genai.protos.Tool(
    function_declarations=[
        genai.protos.FunctionDeclaration(
            name="updateUserSettings",
            description="Updates the user's settings in the database.",
            parameters=genai.protos.Schema(
                type=genai.protos.Type.OBJECT,
                properties={
                    "name": genai.protos.Schema(type=genai.protos.Type.STRING, description="The user's full name."),
                    "persona": genai.protos.Schema(type=genai.protos.Type.STRING, description="A descriptive persona for the user (e.g., 'Cautious Saver', 'Ambitious Investor')."),
                    "monthlyIncome": genai.protos.Schema(type=genai.protos.Type.NUMBER, description="The user's estimated monthly income."),
                    "currentBalance": genai.protos.Schema(type=genai.protos.Type.NUMBER, description="The user's current bank account balance."),
                    "spendingNature": genai.protos.Schema(type=genai.protos.Type.STRING, description="A summary of the user's spending habits."),
                    "goals": genai.protos.Schema(type=genai.protos.Type.STRING, description="The user's primary financial goals."),
                    "budget": genai.protos.Schema(type=genai.protos.Type.NUMBER, description="The user's desired monthly budget."),
                },
                required=["name", "persona", "monthlyIncome", "currentBalance", "spendingNature", "goals", "budget"],
            ),
        ),
    ]
)

# Define the system prompt for Fin
system_prompt = """You are 'Fin', a friendly, casual, and insightful financial onboarding assistant. Your primary job is to have a natural conversation to understand the user's financial life.

Your Goal: Fill in all the details for the 'updateUserSettings' function. Do not ask for all the information at once. Weave your questions into a casual, back-and-forth conversation.

Your Persona: Be encouraging and empathetic.

Example Snippets (Few-Shot Prompts):
- Instead of: 'What is your monthly income?', ask: 'Roughly what does your monthly income look like? No need for exact numbers, just a ballpark is fine.'
- Instead of: 'What are your savings goals?', ask: 'Cool, so what are you saving up for? A big trip, a new car, or just building up a safety net?'

Once you are confident you have gathered enough information for all the parameters, you MUST call the 'updateUserSettings' function with the data you've collected."""

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.post("/agenticOnboarding", response_model=OnboardingResponse)
async def agentic_onboarding(request: OnboardingRequest):
    print(f"Received message from {request.userId}: {request.message}")
    print(f"Conversation history: {request.history}")

    # Convert Flutter history to Gemini format
    gemini_history = []
    for msg in request.history:
        role = "user" if msg.isFromUser else "model"
        gemini_history.append({"role": role, "parts": [{"text": msg.text}]})

    # Initialize the Gemini model
    model = genai.GenerativeModel(
        model_name="gemini-1.5-flash-latest",
        tools=[update_user_settings_tool],
        system_instruction=system_prompt
    )

    chat = model.start_chat(history=gemini_history)

    try:
        response = chat.send_message(request.message)
        ai_response_text = ""
        is_done = False

        # FIX: Correctly parse the response by iterating through its parts.
        # This prevents trying to access `.text` when the response is a function call.
        if response.candidates and response.candidates[0].content and response.candidates[0].content.parts:
            for part in response.candidates[0].content.parts:
                # Check if the part is a function call
                if part.function_call:
                    function_call = part.function_call
                    if function_call.name == "updateUserSettings":
                        args = {k: v for k, v in function_call.args.items()}
                        print(f"Gemini called updateUserSettings with args: {args}")
                        ai_response_text = "Awesome! I've gathered all the necessary information. You're all set for personalized financial insights!"
                        is_done = True
                        break # Exit the loop after finding the function call
                    else:
                        ai_response_text = "I received an unexpected function call."
                # If the part is text
                elif part.text:
                    ai_response_text += part.text
                    
        if not ai_response_text:
            ai_response_text = "I'm sorry, I couldn't generate a response."

        return OnboardingResponse(response=ai_response_text, isDone=is_done)

    except Exception as e:
        print(f"Error communicating with Gemini: {e}")
        raise HTTPException(status_code=500, detail=f"Error communicating with AI: {e}")
# To run this app:
# 1. Install dependencies: pip install fastapi "uvicorn[standard]" pydantic google-generativeai
# 2. Run the server: uvicorn main:app --reload --host 0.0.0.0

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8081)
