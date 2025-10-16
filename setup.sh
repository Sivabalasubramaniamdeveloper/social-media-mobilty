#!/bin/bash

echo "🚀 Flutter Project Setup Initialized"
echo "-------------------------------------"

# Run flutter pub get
echo "🔄 Running flutter pub get..."
flutter pub get
flutter pub global activate rename

# Collect user input
read -p "📢 Enter your app name: " APP_NAME
read -p "📢 Enter your base package name (e.g., com.example.app): " PACKAGE_NAME
read -p "📢 Enter comma-separated flavor names (e.g., dev,sit,uat,prod): " FLAVOR_INPUT

echo "✅ App Name: $APP_NAME"
echo "✅ Package Name: $PACKAGE_NAME"
DART_PACKAGE='flutter_automation'
echo "✅ Dart Import Name: $DART_PACKAGE"
[ -n "$ICON_PATH" ] && echo "✅ Icon Path: $ICON_PATH" || echo "Setting default icon..."
echo "✅ Flavors: $FLAVOR_INPUT"

# Flavors
if [ -n "$FLAVOR_INPUT" ]; then
  IFS=',' read -ra FLAVORS <<< "$FLAVOR_INPUT"
else
  FLAVOR_INPUT='sit,uat,prod'
  IFS=',' read -ra FLAVORS <<< "$FLAVOR_INPUT"
fi

# Rename app
if [ -n "$APP_NAME" ]; then
  echo "Renaming app to $APP_NAME..."
  flutter pub run rename setAppName --targets ios,android --value "$APP_NAME"
else
  APP_NAME='exampleapp'
  echo "Renaming app to $APP_NAME..."
  flutter pub run rename setAppName --targets ios,android --value "$APP_NAME"
  echo "Setting default app name."
fi

# Rename package
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

# Launcher icon
if [ -n "$ICON_PATH" ]; then
  echo "Setting launcher icon..."
  cat > pubspec_launcher_icons.yaml <<EOL
flutter_icons:
  android: true
  ios: true
  image_path: "$ICON_PATH"
EOL
  flutter pub run flutter_launcher_icons:main -f pubspec_launcher_icons.yaml
  rm pubspec_launcher_icons.yaml
else
  echo "Setting default App icon...."
fi

# --------- Generate lib/flavor folder and config ---------
mkdir -p lib/config/flavor

# Build flavor_config.dart
FLAVOR_ENUMS=""
TITLE_SWITCH=""
IS_DEV_SWITCH=""
IS_APP_SWITCH=""

for FLAVOR in "${FLAVORS[@]}"; do
  FLAVOR_UPPER=$(echo "$FLAVOR" | tr '[:lower:]' '[:upper:]')
  FLAVOR_ENUMS+="$FLAVOR, "
  TITLE_SWITCH+=" case Flavor.$FLAVOR:
      return '$APP_NAME $FLAVOR_UPPER';"

  if [[ "$FLAVOR" == "prod" ]]; then
    IS_DEV_SWITCH+="case Flavor.$FLAVOR:
        return false;"
  else
    IS_DEV_SWITCH+="case Flavor.$FLAVOR:
        return true;"
  fi

  IS_APP_SWITCH+="case Flavor.$FLAVOR:
      return true;"
done

# Remove trailing comma
FLAVOR_ENUMS=$(echo "$FLAVOR_ENUMS" | sed 's/, $//')

cat > lib/config/flavor/flavor_config.dart <<EOL
enum Flavor {
  $FLAVOR_ENUMS
}

class FlavorConfig {
  static Flavor? appFlavor;

  static String get title {
    switch (appFlavor) {
$TITLE_SWITCH
      default:
        return '$APP_NAME';
    }
  }

  static bool get isDevelopment {
    switch (appFlavor) {
$IS_DEV_SWITCH
      default:
        return false;
    }
  }

  static bool get is$APP_NAME {
    switch (appFlavor) {
$IS_APP_SWITCH
      default:
        return true;
    }
  }
}
EOL

echo " Generated lib/config/flavor/flavor_config.dart"

# --------- Create main entry for each flavor ----------
for FLAVOR in "${FLAVORS[@]}"; do
  FILE_PATH="lib/config/flavor/${FLAVOR}.dart"
  echo " Creating $FILE_PATH"
  cat > "$FILE_PATH" <<EOL
import 'flavor_config.dart';
import 'package:$DART_PACKAGE/main.dart' as app;

Future<void> main() async {
  FlavorConfig.appFlavor = Flavor.$FLAVOR;
  await app.main();
}
EOL
done

echo " Created entry point Dart files in lib/config/flavor/"

# --------- Update AndroidManifest.xml ----------
MANIFEST="android/app/src/main/AndroidManifest.xml"
if grep -q 'android:label=' "$MANIFEST"; then
  sed -i.bak 's/android:label="[^"]*"/android:label="@string\/app_name"/' "$MANIFEST"
  rm -f "${MANIFEST}.bak"
  echo " Updated AndroidManifest.xml label to @string/app_name"
else
  echo " android:label not found in AndroidManifest.xml"
fi
# ---------- Update Info.plist ----------
INFO_PLIST="ios/Runner/Info.plist"

if grep -q "<key>CFBundleDisplayName</key>" "$INFO_PLIST"; then
  # Replace the next <string> value with $(PRODUCT_NAME)
  # shellcheck disable=SC2016
  sed -i.bak '/<key>CFBundleDisplayName<\/key>/{n;s#<string>.*</string>#<string>$(PRODUCT_NAME)</string>#}' "$INFO_PLIST"
  rm -f "${INFO_PLIST}.bak"
  echo "✅ Updated Info.plist CFBundleDisplayName to use PRODUCT_NAME"
else
  echo "⚠️ CFBundleDisplayName key not found in Info.plist"
fi

# --------- Detect Gradle build file ---------
GRADLE_FILE=""
if [ -f android/app/build.gradle.kts ]; then
  GRADLE_FILE="android/app/build.gradle.kts"
elif [ -f android/app/build.gradle ]; then
  GRADLE_FILE="android/app/build.gradle"
else
  echo " No build.gradle or build.gradle.kts found in android/app/"
  exit 1
fi

# Clean old flavor configs
sed -i.bak '/flavorDimensions/d' "$GRADLE_FILE"
sed -i.bak '/productFlavors {/,/^\s*}/d' "$GRADLE_FILE"
rm -f "${GRADLE_FILE}.bak"

echo " Updating namespace to $PACKAGE_NAME..."
sed -i '' "s/namespace\s*=.*/namespace = \"$PACKAGE_NAME\"/" "$GRADLE_FILE"
echo " Namespace updated to $PACKAGE_NAME"

echo " Configuring flavors in $GRADLE_FILE..."

# Build flavor block
if [[ "$GRADLE_FILE" == *".kts" ]]; then
  FLAVOR_BLOCK='        flavorDimensions += "flavor-type"\n'
  FLAVOR_BLOCK+='        productFlavors {\n'
  for FLAVOR in "${FLAVORS[@]}"; do
    FLAVOR_UPPER=$(echo "$FLAVOR" | tr '[:lower:]' '[:upper:]')
    if [[ "$FLAVOR" == "prod" ]]; then
      FLAVOR_BLOCK+="            create(\"$FLAVOR\") {\n"
      FLAVOR_BLOCK+='                dimension = "flavor-type"\n'
      FLAVOR_BLOCK+="                applicationId = \"$PACKAGE_NAME\"\n"
      FLAVOR_BLOCK+="                resValue(\"string\", \"app_name\", \"$APP_NAME\")\n"
      FLAVOR_BLOCK+="            }\n"
    else
      FLAVOR_BLOCK+="            create(\"$FLAVOR\") {\n"
      FLAVOR_BLOCK+='                dimension = "flavor-type"\n'
      FLAVOR_BLOCK+="                applicationId = \"$PACKAGE_NAME.$FLAVOR\"\n"
      FLAVOR_BLOCK+="                resValue(\"string\", \"app_name\", \"$APP_NAME $FLAVOR_UPPER\")\n"
      FLAVOR_BLOCK+="            }\n"
    fi
  done
  FLAVOR_BLOCK+='        }\n'
else
  FLAVOR_BLOCK='        flavorDimensions "flavor-type"\n'
  FLAVOR_BLOCK+='        productFlavors {\n'
  for FLAVOR in "${FLAVORS[@]}"; do
    FLAVOR_UPPER=$(echo "$FLAVOR" | tr '[:lower:]' '[:upper:]')
    if [[ "$FLAVOR" == "prod" ]]; then
      FLAVOR_BLOCK+="            $FLAVOR {\n"
      FLAVOR_BLOCK+='                dimension "flavor-type"\n'
      FLAVOR_BLOCK+="                applicationId \"$PACKAGE_NAME\"\n"
      FLAVOR_BLOCK+="                resValue \"string\", \"app_name\", \"$APP_NAME\"\n"
      FLAVOR_BLOCK+='            }\n'
    else
      FLAVOR_BLOCK+="            $FLAVOR {\n"
      FLAVOR_BLOCK+='                dimension "flavor-type"\n'
      FLAVOR_BLOCK+="                applicationId \"$PACKAGE_NAME.$FLAVOR\"\n"
      FLAVOR_BLOCK+="                resValue \"string\", \"app_name\", \"$APP_NAME $FLAVOR_UPPER\"\n"
      FLAVOR_BLOCK+='            }\n'
    fi
  done
  FLAVOR_BLOCK+='        }\n'
fi

# Inject flavor block before buildTypes
awk -v block="$FLAVOR_BLOCK" '
  /buildTypes\s*{/ { print block }
  { print }
' "$GRADLE_FILE" > temp.gradle && mv temp.gradle "$GRADLE_FILE"

echo " Flavors added to $GRADLE_FILE"

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


echo "🎉 Setup complete!"
