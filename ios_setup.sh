#!/bin/bash

PROJECT_YML="ios/project.yml"

# Flavors you want
FLAVORS=("sit" "uat" "prod")

# Start fresh
cat > $PROJECT_YML <<EOL
name: Runner
options:
  bundleIdPrefix: com.siva.app
configs:
  Debug: debug
  Release: release
EOL

# Add configs per flavor
for FLAVOR in "${FLAVORS[@]}"; do
cat >> $PROJECT_YML <<EOL
  Debug-$FLAVOR: debug
  Release-$FLAVOR: release
EOL
done

cat >> $PROJECT_YML <<EOL

targets:
  Runner:
    type: application
    platform: iOS
    sources: [Runner]
    settings:
      base:
        PRODUCT_NAME: \$(TARGET_NAME)
        PRODUCT_BUNDLE_IDENTIFIER: com.siva.app
      configs:
EOL

# Add bundle id + product name per flavor
# Add bundle id + product name per flavor
for FLAVOR in "${FLAVORS[@]}"; do
  if [ "$FLAVOR" == "prod" ]; then
    # Prod has no suffix
    cat >> $PROJECT_YML <<EOL
        Debug-$FLAVOR:
          PRODUCT_BUNDLE_IDENTIFIER: com.siva.app
          PRODUCT_NAME: MyApp
        Release-$FLAVOR:
          PRODUCT_BUNDLE_IDENTIFIER: com.siva.app
          PRODUCT_NAME: MyApp
EOL
  else
    # Convert flavor name to uppercase once (outside heredoc)
    UPPER=$(echo "$FLAVOR" | tr '[:lower:]' '[:upper:]')

    cat >> $PROJECT_YML <<EOL
        Debug-$FLAVOR:
          PRODUCT_BUNDLE_IDENTIFIER: com.siva.app.$FLAVOR
          PRODUCT_NAME: MyApp-$UPPER
        Release-$FLAVOR:
          PRODUCT_BUNDLE_IDENTIFIER: com.siva.app.$FLAVOR
          PRODUCT_NAME: MyApp-$UPPER
EOL
  fi
done


cat >> $PROJECT_YML <<EOL

schemes:
EOL

# Add schemes per flavor
for FLAVOR in "${FLAVORS[@]}"; do
cat >> $PROJECT_YML <<EOL
  $FLAVOR:
    build:
      targets:
        Runner: all
    run:
      config: Debug-$FLAVOR
EOL
done

# Run XcodeGen
cd ios
xcodegen generate
cd ..
