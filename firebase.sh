#!/bin/bash
read -p "Are you need to Initialize Firebase (Answer yes/no): " FIREBASE_OPTION

echo "🔍 Checking Node.js installation..."

  # shellcheck disable=SC1073
  if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed!"
    echo "➡️ Please install Node.js from https://nodejs.org/"
    echo "💡 Or use this command on Windows with Chocolatey:"
    echo "   choco install nodejs -y"
    exit 1
  else
    echo "✅ Node.js version: $(node --version)"
  fi

  echo "🔍 Checking npm installation..."

  if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed!"
    echo "➡️ npm usually comes with Node.js. Reinstall Node.js from https://nodejs.org/"
    exit 1
  else
    echo "✅ npm version: $(npm --version)"
  fi

  echo "⚙️ Installing Firebase CLI globally..."
  npm install -g firebase-tools

  # shellcheck disable=SC2181
  if [ $? -eq 0 ]; then
    echo "✅ Firebase CLI installed successfully."
  else
    echo "❌ Firebase CLI installation failed!"
    exit 1
  fi

  echo "🔐 Logging into Firebase..."
  firebase login
  read -p "Enter your Project ID (Take from console): " PROJECT_ID
  read -p "Enter your base bundle ID (e.g., com.example.app): " BASE_BUNDLE_ID
 echo 'Take you path (C:/Users/SivabalaSubramaniamP/AppData/Local/Pub/Cache/bin)'
  read -p "Give you path: " FLUTTERFIREPATH
  echo  "$FLUTTERFIREPATH"
  # Run the command
  echo "🚀 Running command: $FLUTTERFIREPATH/flutterfire.bat configure --project $PROJECT_ID"
FLUTTER_CMD=("$FLUTTERFIREPATH/flutterfire.bat" configure --project "$PROJECT_ID")

# shellcheck disable=SC2145
echo "🚀 Running command: ${FLUTTER_CMD[@]}"
"${FLUTTER_CMD[@]}"


  # If command succeeded, update main.dart
  # shellcheck disable=SC2181
  if [ $? -eq 0 ]; then
    echo "✅ Firebase command executed successfully."

      flutter pub add firebase_core
      # Define the main Dart file path
      MAIN_DART_FILE="lib/main.dart"

      if ! grep -q "import 'firebase_options.dart';" "$MAIN_DART_FILE"; then
        sed -i "1i import 'firebase_options.dart';" "$MAIN_DART_FILE"
      fi
      rm -f "lib/main.dart.bak"

      echo "✅ Injected Firebase.initializeApp into \$MAIN_DART_FILE"


      echo "✅ Injected Firebase.initializeApp into $MAIN_DART_FILE"
       APP_ID=$(firebase apps:list ANDROID --project "$PROJECT_ID" | grep "$BASE_BUNDLE_ID" | grep -oE '[0-9]+:[0-9]+:android:[a-f0-9]+')
            echo "✅ App ID: $APP_ID"

              # Download google-services.json

              DEST_PATH="android/app/src/prod"
              mkdir -p "$DEST_PATH"
                echo "⬇️ Downloading google-services.json for prod..."

            firebase apps:sdkconfig ANDROID "$APP_ID" | grep -A100 "{" > "android/app/src/prod/google-services.json"


              echo "📄 Placed google-services.json for prod at $DEST_PATH"
              git add -f "android/app/src/prod/google-services.json"

                echo "✅ prod flavor setup completed!"
      echo ""
      echo " Put this in your main function in main.dart file"
      echo '
               WidgetsFlutterBinding.ensureInitialized();
                await Firebase.initializeApp(
                  options: DefaultFirebaseOptions.currentPlatform);
               '
    echo ''
fi
  read -p "📢 Enter comma-separated flavor names (Expect production :e.g., dev,sit,uat): " FLAVOR_INPUT

   # Flavors
    if [ -n "$FLAVOR_INPUT" ]; then
    # Parse flavors into array
    IFS=',' read -ra FLAVORS <<< "$FLAVOR_INPUT"
    else
      FLAVOR_INPUT='sit,uat'
    # Parse flavors into array
    IFS=',' read -ra FLAVORS <<< "$FLAVOR_INPUT"
    fi

    # shellcheck disable=SC2128
 for FLAVOR in "${FLAVORS[@]}"; do
      echo "📱 Adding Android app..."
      ANDROID_BUNDLE_ID="${BASE_BUNDLE_ID}.${FLAVOR}"
      echo ANDROID_BUNDLE_ID
      echo "$FLAVOR"
          echo "$FLAVOR"
          echo "$FLAVOR"
          echo '===================================================================='
          echo "To confirm the bundle ID type this bundle ID in terminal"
          echo "$ANDROID_BUNDLE_ID"
          echo '===================================================================='
          firebase apps:create ANDROID "$ANDROID_BUNDLE_ID" --project="$PROJECT_ID"

      APP_ID=$(firebase apps:list ANDROID --project "$PROJECT_ID" | grep "$ANDROID_BUNDLE_ID" | grep -oE '[0-9]+:[0-9]+:android:[a-f0-9]+')
      echo "✅ App ID: $APP_ID"

        # Download google-services.json

        DEST_PATH="android/app/src/$FLAVOR"
        mkdir -p "$DEST_PATH"
          echo "⬇️ Downloading google-services.json for $FLAVOR..."

      firebase apps:sdkconfig ANDROID "$APP_ID" | grep -A100 "{" > "android/app/src/${FLAVOR}/google-services.json"


        echo "📄 Placed google-services.json for $FLAVOR at $DEST_PATH"
        git add -f "android/app/src/${FLAVOR}/google-services.json"

          echo "✅ ${FLAVOR} flavor setup completed!"
      done

