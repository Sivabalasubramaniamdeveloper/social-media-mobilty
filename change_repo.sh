 echo "🔄 Changing Git remote repository..."
 echo ""
 echo "Create a new GitHub repository...."
 echo ""
 echo "Go to GitHub → click New repository → note the new repo URL (e.g. https://github.com/yourname/new-repo.git)....."
 echo ""
  read -p "👉 Enter your new GitHub repository URL (eg: https://github.com/yourname/new-repo.git): " NEW_REPO

  if [ -z "$NEW_REPO" ]; then
    echo "❌ No repository URL provided. Aborting."
    exit 1
  fi

  git remote remove origin
  git remote add origin "$NEW_REPO"

  CURRENT_BRANCH=$(git branch --show-current)

  echo "📤 Pushing current branch '$CURRENT_BRANCH' to new remote..."
  git push -u origin "$CURRENT_BRANCH"

  echo "✅ Git remote changed and pushed to: $NEW_REPO"