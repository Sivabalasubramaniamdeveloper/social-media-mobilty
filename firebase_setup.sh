#!/bin/bash

read -p "Are you need to Initialize Firebase (Answer yes/no): " FIREBASE_OPTION

if [[ "$FIREBASE_OPTION" == "yes" || "$FIREBASE_OPTION" == "y" ]]; then
  echo ''

  # Check Node.js
  if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed!"
    exit 1
  else
    echo "✅ Node.js version: $(node --version)"
  fi

  # Check npm
  if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed!"
    exit 1
  else
    echo "✅ npm version: $(npm --version)"
  fi

  # Install Firebase CLI
  if ! command -v firebase &> /dev/null; then
    echo "⚙️ Installing Firebase CLI..."
    npm install -g firebase-tools
  fi

  # Install flutterfire_cli
  if ! command -v flutterfire &> /dev/null; then
    echo "⚙️ Installing flutterfire_cli..."
    dart pub global activate flutterfire_cli
  fi

  # Login to Firebase
  firebase login

  # Get inputs
  read -p "Enter your base project name: " PROJECT_NAME
  read -p "Enter your base bundle ID (e.g., com.example.app): " BASE_BUNDLE_ID
  read -p "Enter flavors (space-separated, e.g., sit uat prod): " FLAVORS
  RAND_NUM=$((RANDOM % 9000 + 1000))
  PROJECT_ID="${PROJECT_NAME,,}-${RAND_NUM}"
#  PROJECT_ID='oilrig-7784'
  echo "🚀 Creating Firebase Project: $PROJECT_ID"
#  firebase projects:create "$PROJECT_ID" --display-name "${PROJECT_NAME^}" || {
#    echo "❌ Failed to create project!";
#    cat firebase-debug.log
#     exit 1;
#     }

  for FLAVOR in $FLAVORS; do
    if [ "$FLAVOR" == "prod" ]; then
        echo "📱 Adding Android app..."
        ANDROID_BUNDLE_ID="$BASE_BUNDLE_ID"
        echo ANDROID_BUNDLE_ID
    else
        echo "📱 Adding Android app..."
        ANDROID_BUNDLE_ID="${BASE_BUNDLE_ID}.${FLAVOR}"
        echo ANDROID_BUNDLE_ID
    fi
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

  echo "🎯 All flavors configured!"
else
  echo "⏩ Skipping Firebase initialization."
fi
