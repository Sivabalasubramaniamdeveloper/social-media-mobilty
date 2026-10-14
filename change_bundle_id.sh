#!/bin/bash
read -p "📢 Enter your base package name (e.g., com.example.app): " PACKAGE_NAME
echo "✅ Package Name: $PACKAGE_NAME"

GRADLE_FILE="android/app/build.gradle.kts"

# Rename bundle ID (using flutter_rename package)
if [ -n "$PACKAGE_NAME" ]; then
  echo "Renaming bundle ID to $PACKAGE_NAME..."
  flutter pub run rename setBundleId --targets android --value "$PACKAGE_NAME"
  flutter pub run rename setBundleId --targets ios --value "$PACKAGE_NAME"
else
  PACKAGE_NAME='com.example.app'
  echo "Renaming bundle ID to $PACKAGE_NAME..."
  flutter pub run rename setBundleId --targets android --value "$PACKAGE_NAME"
  flutter pub run rename setBundleId --targets ios --value "$PACKAGE_NAME"
  echo "Setting default package name."
fi

# ✅ Update namespace (with indentation support)
sed -i "s/^[[:space:]]*namespace = .*/    namespace = \"$PACKAGE_NAME\"/" $GRADLE_FILE



# --------- Kotlin package restructure ----------
KOTLIN_DIR="android/app/src/main/kotlin"
PACKAGE_PATH="$(echo "$PACKAGE_NAME" | tr '.' '/')"
NEW_PACKAGE_DIR="$KOTLIN_DIR/$PACKAGE_PATH"

rm -rf "$KOTLIN_DIR"
mkdir -p "$NEW_PACKAGE_DIR"

cat > "$NEW_PACKAGE_DIR/MainActivity.kt" <<EOL
package $PACKAGE_NAME

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}
EOL
git add .
echo " Created MainActivity.kt with correct package declaration"

