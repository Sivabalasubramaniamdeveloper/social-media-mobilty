#!/usr/bin/env bash
set -euo pipefail

OLD="flutter_automation"
NEW="${1:-}"

if [[ -z "${NEW}" ]]; then
  read -r -p "Enter new project/package name (e.g. my_app): " NEW
fi
NEW="${NEW## }"; NEW="${NEW%% }"
if [[ -z "${NEW}" ]]; then
  echo "Name cannot be empty." >&2
  exit 1
fi

# Resolve repo root as the directory this script lives in
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# Exclusions
prune_args=(
  -path "$ROOT/.git" -prune -o
  -path "$ROOT/build" -prune -o
  -path "$ROOT/.dart_tool" -prune -o
  -path "$ROOT/.idea" -prune -o
  -path "$ROOT/.vscode" -prune -o
  -path "$ROOT/ios/Pods" -prune -o
  -path "$ROOT/android/.gradle" -prune -o
  -path "$ROOT/android/build" -prune -o
)

# File extensions to process for in-file replacement
ext_predicate=(
  -iname '*.dart' -o -iname '*.yaml' -o -iname '*.yml' -o -iname '*.xml' -o -iname '*.gradle' -o 
  -iname '*.kt' -o -iname '*.java' -o -iname '*.plist' -o -iname '*.md' -o -iname '*.json' -o 
  -iname '*.sh' -o -iname '*.ps1' -o -iname '*.bat' -o -iname '*.cfg' -o -iname '*.properties' -o 
  -iname '*.txt' -o -iname '*.swift' -o -iname '*.mm' -o -iname '*.m' -o -iname '*.h' -o -iname '*.xcconfig'
)

echo "Replacing occurrences of '$OLD' with '$NEW' under $ROOT ..."

# Gather files for content replacement
mapfile -d '' FILES < <(find "$ROOT" "${prune_args[@]}" -type f \( "${ext_predicate[@]}" \) -print0)

if command -v perl >/dev/null 2>&1; then
  for f in "${FILES[@]}"; do
    perl -0777 -pe "s/\Q$OLD\E/$NEW/g" -i "$f" || true
  done
else
  # sed fallback (GNU/BSD compatible in-place handling)
  if sed --version >/dev/null 2>&1; then SED_IN=("-i"); else SED_IN=("-i" ""); fi
  s_OLD=$(printf '%s' "$OLD" | sed -e 's/[\\/&|]/\\&/g')
  s_NEW=$(printf '%s' "$NEW" | sed -e 's/[\\/&|]/\\&/g')
  for f in "${FILES[@]}"; do
    sed "${SED_IN[@]}" -e "s|${s_OLD}|${s_NEW}|g" "$f" || true
  done
fi

# Fix package imports in Dart files
echo "Fixing package imports..."
find "$ROOT/lib" -name '*.dart' -type f -print0 2>/dev/null | while IFS= read -r -d '' f; do
  if command -v perl >/dev/null 2>&1; then
    perl -0777 -pe "s/package:$OLD/package:$NEW/g" -i "$f" || true
  else
    if sed --version >/dev/null 2>&1; then SED_IN=("-i"); else SED_IN=("-i" ""); fi
    sed "${SED_IN[@]}" -e "s|package:${OLD}|package:${NEW}|g" "$f" || true
  fi
done

# Rename files and directories containing the old name (depth-first)
find "$ROOT" -depth \
  "${prune_args[@]}" \
  -name "*${OLD}*" -print0 | while IFS= read -r -d '' p; do
    base="$(basename -- "$p")"
    dir="$(dirname -- "$p")"
    newbase="${base//${OLD}/${NEW}}"
    if [[ "$newbase" != "$base" ]]; then
      mv -v -- "$p" "$dir/$newbase" || true
    fi
  done

echo "Done. You may want to run: flutter clean && flutter pub get"
