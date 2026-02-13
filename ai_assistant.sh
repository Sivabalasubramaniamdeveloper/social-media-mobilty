# #!/bin/bash

# # === Configuration ===
# MODEL="gpt-4o-mini"
# ENV_FILE=".env"

# # --- Load API Key ---
# if [ -f "$ENV_FILE" ]; then
#   # shellcheck disable=SC2046
#   export $(grep -v '^#' "$ENV_FILE" | xargs)
# fi

# API_KEY="${OPENAI_API_KEY:?Error: OPENAI_API_KEY not set in environment. Add it in .env or export it.}"


# #read -p "Enter your api-key"

# echo "🤖 AI Assistant - Type 'exit' to quit."
#     echo "=========================="
#     echo "🤖 AI Assistant Menu"
#     echo "1️⃣ Just chat with AI"
#     echo "2️⃣ Get Flutter/Dart code from AI"
#     echo "3️⃣ Exit"
#     echo "=========================="
#     read -p "Choose an option (1-3): " OPTION

# while true; do
#   echo "exit --> Exit from the task"
#     case $OPTION in
#         1)
#             read -p "You: " USER_INPUT
#             if [[ "$USER_INPUT" == "exit" ]]; then
#                     echo "Goodbye! 👋"
#                     break
#             fi
#             RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
#                 -H "Content-Type: application/json" \
#                 -H "Authorization: Bearer $API_KEY" \
#                 -d "{
#                     \"model\": \"$MODEL\",
#                     \"messages\": [
#                         {\"role\": \"system\", \"content\": \"You are a helpful assistant.\"},
#                         {\"role\": \"user\", \"content\": \"$USER_INPUT\"}
#                     ]
#                 }")

#             echo "AI: $(echo "$RESPONSE" | jq -r '.choices[0].message.content')"
#             ;;

#         2)
#             read -p "Describe the Flutter/Dart code you need: " USER_INPUT
#             if [[ "$USER_INPUT" == "exit" ]]; then
#                     echo "Goodbye! 👋"
#                     break
#             fi
#             RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
#                 -H "Content-Type: application/json" \
#                 -H "Authorization: Bearer $API_KEY" \
#                 -d "{
#                     \"model\": \"$MODEL\",
#                     \"messages\": [
#                         {\"role\": \"system\", \"content\": \"You are a Flutter expert. Respond ONLY with clean Dart code inside triple backticks.\"},
#                         {\"role\": \"user\", \"content\": \"$USER_INPUT\"}
#                     ]
#                 }")

#             CODE=$(echo "$RESPONSE" | jq -r '.choices[0].message.content' | sed 's/```dart//g' | sed 's/```//g')
#             read -p "📄 Enter the file name (without .dart): " FILE_NAME
#             read -p "📄 Enter the folder path where $FILE_NAME must be created (eg: features/screens ): " FOLDER_PATH
#             echo "$CODE" > "lib/$FOLDER_PATH/$FILE_NAME.dart"
#             echo "✅ Dart file created: lib/$FOLDER_PATH/$FILE_NAME.dart"
#             git add -f lib/"$FOLDER_PATH"/"$FILE_NAME.dart"
#             ;;

#         3)
#             echo "Goodbye! 👋"
#             break
#             ;;
#         *)
#             echo "❌ Invalid option. Please choose 1-3."
#             ;;
#     esac
# done
