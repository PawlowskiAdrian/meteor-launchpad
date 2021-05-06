#!/bin/bash

set -e
TMP_DIR=/tmp
# $(pwd)

if [ "$DEV_BUILD" = true ]; then
  # if this is a devbuild, we don't have an app to check the .meteor/release file yet,
  # so just install the latest version of Meteor
  printf "\n[-] Installing the latest version of Meteor...\n\n"
  curl -v https://install.meteor.com/ | sh
else
  # download installer script
  curl -v https://install.meteor.com -o $TMP_DIR/install_meteor.sh

  # read in the release version in the app
  METEOR_VERSION=$(head $APP_SOURCE_DIR/.meteor/release | cut -d "@" -f 2)

  # set the release version in the install script
  sed -i.bak "s/RELEASE=.*/RELEASE=\"$METEOR_VERSION\"/g" $TMP_DIR/install_meteor.sh

  # replace tar command with bsdtar in the install script (bsdtar -xf "$TARBALL_FILE" -C "$INSTALL_TMPDIR")
  # https://github.com/jshimko/meteor-launchpad/issues/39
  sed -i.bak "s/tar -xzf.*/bsdtar -xf \"\$TARBALL_FILE\" -C \"\$INSTALL_TMPDIR\"/g" $TMP_DIR/install_meteor.sh

  # install
  printf "\n[-] Installing Meteor $METEOR_VERSION...\n\n"
  sh $TMP_DIR/install_meteor.sh
fi
