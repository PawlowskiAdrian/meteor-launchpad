#!/bin/bash
set -e

TMP_DIR=/tmp

# ============================================
# Ensure Python 2.7 is used for any node-gyp builds
# ============================================
if [ -x "/usr/local/bin/python2.7" ]; then
    export PYTHON=/usr/local/bin/python2.7
    npm config set python /usr/local/bin/python2.7 2>/dev/null || true
fi

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

    # replace tar command with bsdtar in the install script
    # https://github.com/jshimko/meteor-launchpad/issues/39
    sed -i.bak "s/tar -xzf.*/tar -xf \"\$TARBALL_FILE\" -C \"\$INSTALL_TMPDIR\"/g" $TMP_DIR/install_meteor.sh

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

# ============================================
# Configure Meteor's internal npm to use Python 2.7
# This ensures native modules built via `meteor npm` use correct Python
# ============================================
if [ -x "/usr/local/bin/python2.7" ]; then
    printf "\n[-] Configuring Meteor npm to use Python 2.7...\n\n"
    meteor npm config set python /usr/local/bin/python2.7 || true
fi

printf "\n[-] Meteor installation complete!\n\n"