#!/bin/bash
#
# builds a production meteor bundle directory
#
set -e

if [ -f "$APP_SOURCE_DIR"/launchpad.conf ]; then
  source <(grep TOOL_NODE_FLAGS "$APP_SOURCE_DIR"/launchpad.conf)
fi

# set up npm auth token if one is provided
if [[ "$NPM_TOKEN" ]]; then
  echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" >> ~/.npmrc
fi

# Fix permissions warning in Meteor >=1.4.2.1 without breaking
# earlier versions of Meteor with --unsafe-perm or --allow-superuser
# https://github.com/meteor/meteor/issues/7959
export METEOR_ALLOW_SUPERUSER=true
cd "$APP_SOURCE_DIR"

# Build the bundle
printf "\n[-] Building Meteor application...\n\n"
mkdir -p "$APP_BUNDLE_DIR"
meteor build --directory "$APP_BUNDLE_DIR" --server-only

# Production npm install in bundle
printf "\n[-] Running meteor npm install in the server bundle...\n\n"
cd "$APP_BUNDLE_DIR"/bundle/programs/server/

meteor npm install --production --verbose

# Put the entrypoint script in WORKDIR
mv "$BUILD_SCRIPTS_DIR"/entrypoint.sh "$APP_BUNDLE_DIR"/bundle/entrypoint.sh

# Fix permissions
chown -R node:node "$APP_BUNDLE_DIR"

printf "\n[-] Meteor build complete!\n\n"