## Step-by-Step Flow of the Onboarding Process

  Here is the journey from the user's perspective, from opening the app to completing onboarding:

  1. App Launch and Initial Check (main.dart & nav.dart)

   1. User Opens App: The app starts.
   2. Authentication Check: The GoRouter logic in lib/flutter_flow/nav/nav.dart immediately checks if a user is
       logged in via Firebase Authentication.
       * If NOT Logged In: The user is automatically sent to the AuthHubScreenWidget to sign in or register.
       * If Logged In: The router proceeds to the next check.
   3. Onboarding Status Check: If the user is logged in, the router makes a request to your Firestore database
      to check the onboarding_completed field on their user document.
       * If `onboarding_completed` is `true`: The user has already completed onboarding, so they are redirected
         to the MainDashWidget.
       * If `onboarding_completed` is `false` or doesn't exist: The user is redirected to the
         AIConversationalOnboardingScreenWidget to begin the onboarding flow.

  2. Starting the Conversation (AIConversationalOnboardingScreenWidget)

   1. Screen Loads: The AIConversationalOnboardingScreenWidget is displayed.
   2. `initState` triggers `_startOrResumeOnboarding`: As soon as the screen is ready, it calls the
      _startOrResumeOnboarding function.
   3. Call to `startOnboarding` Cloud Function: This function makes a secure call to your backend Firebase
      Cloud Function named startOnboarding. It sends the current userId.
   4. Backend Logic: Your startOnboarding Cloud Function on the backend will:
       * Look for an existing, unfinished onboarding session for this user.
       * If one exists, it sends back the existing conversation history.
       * If not, it creates a new session, generates the first welcome message (e.g., "Hi! I'm here to help you
         set up your profile. What's your primary financial goal?"), and sends that back.
   5. UI Updates: The Flutter app receives the initial conversation history from the backend and displays it on
       the screen. The loading indicator is turned off.

  3. The Conversational Loop

   1. User Responds: The user sees the AI's first question and types their answer into the TextFormField.
   2. User Sends Message: The user taps the send button, which triggers the _handleUserMessage function.
   3. UI Updates Immediately: The user's message is instantly added to the UI to make the app feel responsive.
      A loading indicator appears while waiting for the AI's response.
   4. Call to `postToOnboarding` Cloud Function: The app sends the user's message text and the unique
      _onboardingSessionId to your postToOnboarding Cloud Function.
   5. Backend AI Logic: This is where the core AI work happens. Your postToOnboarding function will:
       * Receive the message.
       * Add the user's message to the conversation history in Firestore.
       * Send the entire conversation history to a large language model (like Gemini).
       * The LLM analyzes the conversation and generates the next question or statement.
       * Your function receives the AI's response.
       * It saves the AI's response to the conversation history in Firestore.
       * It determines if the conversation is finished. If so, it sets isDone to true in the session document.
       * It sends the AI's new message and the isDone status back to the Flutter app.
   6. UI Updates with AI Response: The Flutter app receives the AI's response and the isDone flag.
       * It adds the AI's message to the conversation list.
       * The loading indicator is hidden.
       * If isDone is true, the text input field is replaced with the "Finish Setup" button.
       * If isDone is false, the text input field is shown again, and the loop continues.

  4. Finishing Onboarding

   1. User Clicks "Finish Setup": Once the conversation is complete, the user clicks the "Finish Setup" button.
   2. Navigate to Dashboard: The _completeOnboarding function is called, which simply navigates the user to the
       MainDashWidget. The actual work of marking the user as "onboarded" was already handled by the backend
      when it set isDone to true.

  This entire flow creates a seamless, dynamic, and intelligent onboarding experience that can be easily
  updated and improved on the backend without requiring any changes to the app code.

## Frontend Changes:

   * No Hardcoded Questions: The list of questions has been removed. The screen now expects to receive
     conversation history and prompts from a backend service.
   * State Management: The widget now manages the conversation state, including loading indicators and whether
      the conversation is complete.
   * Cloud Functions Integration: It now uses the cloud_functions package to call two functions:
       * startOnboarding: This function is called when the screen loads. It's responsible for creating a new
         onboarding session or resuming an existing one, and it returns the initial conversation history.
       * postToOnboarding: This function is called every time the user sends a message. It sends the user's
         message to the backend and receives the AI's response.
   * Dynamic UI: The UI now dynamically displays the conversation history and shows an input field or a
     "Finish Setup" button depending on the conversation state.

  Backend Setup (Firebase):

  To make this work, you'll need to set up the following in your Firebase project:

  1. Firestore Collections:

   * `wallet_user_collection`: You likely already have this. You'll need to add a few fields to the documents
     in this collection:
       * onboarding_completed (boolean):  Indicates whether the user has completed the onboarding process.
       * persona (string):  Stores the user's persona as determined by the AI.
       * onboarding_answers (map): Stores the user's answers to the onboarding questions.

   * `onboarding_sessions`: This is a new collection to manage the state of each user's onboarding
     conversation. Each document in this collection will represent a single onboarding session and should have
      the following fields:
       * userId (string): The UID of the user this session belongs to.
       * startTime (timestamp): When the session started.
       * lastUpdateTime (timestamp): The last time a message was added to the conversation.
       * isDone (boolean):  Indicates whether the onboarding conversation is complete.
       * messages (array of maps):  An array to store the conversation history. Each map in the array should
         have:
           * text (string): The message content.
           * sender (string):  "user" or "ai".
           * timestamp (timestamp): When the message was sent.

  2. Cloud Functions:

  You'll need to create two new Cloud Functions in your firebase/functions/index.js (or equivalent if you're
   using a different language):

   * `startOnboarding`:
       * Trigger: HTTPS
       * Logic:
           1. Takes a userId as input.
           2. Checks if there's an active onboarding_sessions document for that user.
           3. If not, it creates a new session document and adds the first "welcome" message from the AI to the
               messages array.
           4. It returns the sessionId and the messages array to the client.

   * `postToOnboarding`:
       * Trigger: HTTPS
       * Logic:
           1. Takes a sessionId and a message as input.
           2. Adds the user's message to the messages array in the corresponding onboarding_sessions document.
           3. This is where you integrate with your LLM (e.g., Gemini). You'll send the conversation history to
               the LLM and get a response.
           4. Adds the AI's response to the messages array.
           5. Determines if the conversation is over (based on the LLM's response or your own logic) and
              updates the isDone flag in the session document.
           6. Returns the AI's response and the isDone flag to the client.

  This setup decouples the frontend from the conversational logic, allowing you to easily modify the
  onboarding flow and persona-inference logic in your backend without needing to update the app.