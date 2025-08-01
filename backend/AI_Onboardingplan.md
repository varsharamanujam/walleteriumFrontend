To design an effective AI-powered onboarding screen that is both conversational and able to infer user persona—considering spending nature, asset understanding, and psychological patterns—you’ll want the following architecture and flow:

Conversational AI Onboarding Screen: Logic and Outline
Core Principles
Conversational UI: Questions are presented one at a time in a natural language, chat-style format.

Dynamic Branching: The next question adapts in real-time to the user’s previous answer, ensuring contextual relevance.

Persona Capture: Each answer is mapped to psychological traits (e.g., spender vs. saver, risk-taker vs. cautious, diverse asset knowledge).

Asset Intelligence: Users identify and describe assets organically through conversation, not just by ticking asset types.

Question Tracking: Clearly display progress (e.g., “Question 5 of 15”).

Psychological Focus: Questions probe beliefs, habits, and attitudes, not just facts.

Backend Logic (Pseudocode & Structure)
1. Define Question Bank as JSON
Every question has:

id

question_text

context_tag (e.g., spending, risk, asset, psychology)

answer_type (option, text, number, slider)

options (for option type)

followup_mapping (answer -> next question id, or persona score increment)

visibility_condition (dynamic showing logic)

persona_signal (mapping answers to traits)


json
{
  "id": "q1",
  "question_text": "When you think of your 'assets', what comes to mind first?",
  "context_tag": "asset_definition",
  "answer_type": "option",
  "options": ["Savings", "Gold/Jewelry", "Property", "Stocks/Mutual Funds", "Crypto", "Collectibles/Art", "Other"],
  "followup_mapping": { /* based on chosen option, show different next question */ },
  "persona_signal": { /* e.g., if 'crypto' chosen, increment 'Innovator' persona */ }
}
2. Orchestrate Conversational Flow
Start at question 1, display (“Question 1 of 15”).

On answer, record response.

In backend, update:

Persona trait scores (spender/saver, risk, asset literacy, etc.).

Decide next question (could be “skip” or custom follow-up if specific option chosen).

Return next question to frontend, along with updated question number and, optionally, brief feedback (“Interesting!”, “Got it—let’s dive a bit deeper…”).

3. Calculate and Store Persona
After each question or set, adjust user’s running “persona” profile.

At the end of onboarding, use a scoring algorithm (weighted answers) to decide persona: e.g., “Confident Investor”, “Reluctant Saver”, “Diverse Asset Explorer”, etc.

4. Limit to 15 Questions
Track questions answered (including branches) and cap at 15—making sure coverage of all psychological/asset domains within the question pool.

If some questions are shortened (e.g., user only picks “Savings” as assets, skip crypto/art follow-ups).

5. Present Experience
Question, chat bubble from bot.

User answers via quick-reply buttons, text, sliders, or select menus.

Show “Question X of 15” above each prompt.

Allow “Back” to review and edit previous answers.

Sample Conversational Question Set
Here’s a themed sample flow, with logic for branching:

What comes to your mind when you hear the word “wealth”?

Options: Security, Comfort, Growth, Adventure, Freedom, Something else

When managing your money, do you prefer to keep things...

Very organized, Somewhat managed, Go with the flow, I don’t think about it

Which of these assets do you currently own or care about most?

Savings, Gold, Real estate, Stocks, Crypto, Art/Collectibles, None yet

If “Crypto” chosen, follow up: “What excites you about digital assets?”

How do you generally make spending decisions?

Research everything, Ask trusted people, Go with gut, Impulse, Mix

Imagine you received an unexpected bonus. What are you most likely to do?

Invest/save, Spend on a want, Donate/gift, Plan a trip, Keep for emergency

Do you ever set financial goals for yourself?

Yes, regularly. Occasionally. Rarely/never.

How do you feel about market risks when investing?

Avoid at all costs, Willing if reward is good, Excited by taking risks

On a typical month, do you track what you spend?

Always, Sometimes, Rarely

Which statement fits you best?

I review my holdings regularly.

I prefer to “set and forget.”

I want to learn more but it feels overwhelming.

(Branch if “Art/Collectibles” or “Real estate” above)

How do you value your property/art—by expert appraisal, market trends, or personal attachment?

...continue up to 15, dynamically skipping or diving deeper depending on answers.

Technical Suggestions
Use Google Dialogflow CX for orchestration of stateful conversation/branching.

Store all question/answer pairs in Firestore for later RAG enrichment and repeat onboarding if needed.

Use Vertex AI Gemini to analyze evolving persona and suggest next relevant question.

Build frontend with Flutter, present chat-style interface, “Question X of 15”, and adaptive UI for answer input.

At the conclusion, display a friendly persona summary and ask for confirmation or edits.

This pattern ensures the user feels listened to, data collection is deeper and more accurate, and your agentic AI backend has the structured context it needs to personalize all downstream advice and nudges.