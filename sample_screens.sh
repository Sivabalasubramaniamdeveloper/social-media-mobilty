    generate_login_page() {
      cp scripts/templates/sample_login.dart lib/sample_login.dart
      echo "✅ Login page created at lib/sample_login.dart"
      echo ""
      echo "Use this Login page where you need!!!!!!......."
    }

  echo "📘 Flutter sample UI screen and components - Available Commands:"
  echo ""
  echo " login page                    Get sample login page"
  echo " forget page                   Get sample forget page"
  read -p "📢 Enter your app name: " CMD

  if [[ "$CMD" == "login page" ]]; then
    generate_login_page
    exit
  fi
