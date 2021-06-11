#!/bin/bash

set -e
TMP_DIR=/tmp

if [ -f "$APP_SOURCE_DIR"/launchpad.conf ]; then
  source <(grep METEOR_VERSION_CUSTOM "$APP_SOURCE_DIR"/launchpad.conf)
fi

if [ "$DEV_BUILD" = true ]; then
  # if this is a devbuild, we don't have an app to check the .meteor/release file yet,
  # so just install the latest version of Meteor
  if [ "$METEOR_VERSION_CUSTOM" ]; then
    printf "\n[-] Installing Meteor %s...\n\n" "$METEOR_VERSION_CUSTOM"
    curl -v https://install.meteor.com/ | sh 
    printf "Output folder:\n %s" "$(ls -lRaht ~/.meteor/)"
    printf "User used: %s" "$(whoami)"
    meteor update --release "$METEOR_VERSION_CUSTOM"
  else
    printf "\n[-] Installing the latest version of Meteor...\n\n"
    curl -v https://install.meteor.com/ | sh
  fi
else
  # download installer script
  curl -v https://install.meteor.com -o $TMP_DIR/install_meteor.sh

  # read in the release version in the app
  METEOR_VERSION=$(head "$APP_SOURCE_DIR"/.meteor/release | cut -d "@" -f 2)

  # set the release version in the install script
  sed -i.bak "s/RELEASE=.*/RELEASE=\"$METEOR_VERSION\"/g" $TMP_DIR/install_meteor.sh

  # replace tar command with bsdtar in the install script (bsdtar -xf "$TARBALL_FILE" -C "$INSTALL_TMPDIR")
  # https://github.com/jshimko/meteor-launchpad/issues/39
  sed -i.bak "s/tar -xzf.*/bsdtar -xf \"\$TARBALL_FILE\" -C \"\$INSTALL_TMPDIR\"/g" $TMP_DIR/install_meteor.sh

  # install
  if [ "$METEOR_VERSION_CUSTOM" ]; then
    printf "\n[-] Installing Meteor %s...\n\n" "$METEOR_VERSION_CUSTOM"
    sh $TMP_DIR/install_meteor.sh
    meteor update --release "$METEOR_VERSION_CUSTOM"
  else
    printf "\n[-] Installing Meteor %s...\n\n" "$METEOR_VERSION"
    sh $TMP_DIR/install_meteor.sh
  fi
fi

## fix fibers package errors -> build manually via node-gyp
# meteor npm install fibers
# meteor npm install -g node-gyp
# meteor npm update
# meteor npm audit fix
# printf "==========================fibers fix 2 "
# export PATH=/root/.meteor/packages/meteor-tool/.2.2.0.1j8auib.qcbe++os.linux.x86_64+web.browser+web.browser.legacy+web.cordova/mt-os.linux.x86_64/dev_bundle/bin/:"$PATH"
# /opt/nodejs/bin/node /opt/meteor/src/node_modules/fibers/build
# meteor npm prune -g node-gyp
# printf "==========================fibers fix 3 "
# meteor npm prune fibers
