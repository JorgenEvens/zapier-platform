#!/usr/bin/env bash

# Usage like so:
# ./build-boilerplate.sh
# ./build-boilerplate.sh --debug  # For pushing local changes into the zip file

CONTENTS_DIR='boilerplate'
BUILD_DIR='build-boilerplate'

# This allows us to avoid duplicating files in git
FILES_TO_COPY='zapierwrapper.js'

if [ -d $BUILD_DIR ]; then
   rm -fr $BUILD_DIR
fi

mkdir -p $BUILD_DIR

# Copy files
cp "include/$FILES_TO_COPY" "$CONTENTS_DIR/"

# Get new version
NEW_VERSION="$(node -p "require('./package.json').version")"

FILE="$BUILD_DIR/$NEW_VERSION.zip"

# Update version
bin/update-boilerplate-dependencies.js

# Install dependencies
cd $CONTENTS_DIR && npm install

# Allow pushing "local changes" into the zip file
if [ "$1" == "--debug" ]; then
  cp -R ../src/* node_modules/zapier-platform-core/src/
  cp -R ../node_modules/zapier-platform-legacy-scripting-runner/* node_modules/zapier-platform-legacy-scripting-runner/
  rm -rf node_modules/zapier-platform-core/node_modules
  rm -rf node_modules/zapier-platform-legacy-scripting-runner/node_modules
  rm -rf node_modules/zapier-platform-schema/node_modules
fi

# Build the zip file!
zip -R ../$FILE '*.js' '*.json'\
    '*/darwin*node-6/*.node' '*/darwin*node-7/*.node' '*/darwin*node-8/*.node'\
    '*/linux*node-6/*.node' '*/linux*node-7/*.node' '*/linux*node-8/*.node'

# Revert copied files
rm -f $FILES_TO_COPY

# Remove generated package-lock.json and node_modules
rm -f package-lock.json
rm -fr node_modules
cd ..

# Revert version
bin/update-boilerplate-dependencies.js revert