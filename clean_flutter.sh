#!/bin/bash
echo "🧹 Removing unused imports..."
dart fix --apply

echo "✨ Formatting code..."
dart format .

echo "📦 dart pub global activate pubspec_cleanup..."
dart pub global activate pubspec_cleanup

echo "📦 Cleaning unused packages..."
dart pub global run pubspec_cleanup

echo "✅ Project cleaned successfully!"
