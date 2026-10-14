#!/bin/bash

echo "📦 Enter the package name from pub.dev (e.g., dio): "
read PACKAGE

if [ -z "$PACKAGE" ]; then
  echo "❌ No package entered. Exiting."
  exit 1
fi

# Check if pubspec.yaml exists
if [ ! -f pubspec.yaml ]; then
  echo "❌ pubspec.yaml not found in the current directory. Run this from your Flutter project root."
  exit 1
fi

# Add package to dependencies
echo "➕ Adding '$PACKAGE' to pubspec.yaml..."

# Insert the dependency under dependencies:
echo "🚀 Running flutter pub add $PACKAGE..."
flutter pub add "$PACKAGE"
#flutter pub add http
echo "✅ Package '$PACKAGE' added successfully!"
