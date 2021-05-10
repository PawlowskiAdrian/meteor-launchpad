#!/bin/bash
set -e

printf "\n[-] Performing final cleanup...\n\n"

if [ -f "$APP_SOURCE_DIR"/launchpad.conf ]; then
  source <(grep USERNAME_CUSTOM_PASS "$APP_SOURCE_DIR"/launchpad.conf)
  source <(grep USERNAME_CUSTOM_NAME "$APP_SOURCE_DIR"/launchpad.conf)
fi
# get out of the src dir, so we can delete it
cd "$APP_BUNDLE_DIR"
if [ "$USERNAME_CUSTOM_NAME" != "root" ]; then
    # Clean out docs
    echo "$USERNAME_CUSTOM_PASS" | sudo -S rm -rf /usr/share/{doc,doc-base,man,locale,zoneinfo}

    # Clean out package management dirs
    echo "$USERNAME_CUSTOM_PASS" | sudo -S rm -rf /var/lib/{cache,log}

    # remove app source
    echo "$USERNAME_CUSTOM_PASS" | sudo -S rm -rf "$APP_SOURCE_DIR"

    # remove meteor
    echo "$USERNAME_CUSTOM_PASS" | sudo -S rm -rf /usr/local/bin/meteor
    rm -rf /home/"$(whoami)"/.meteor 

    # clean additional files created outside the source tree
    rm -rf /home/"$(whoami)"/{.npm,.cache,.config,.cordova,.local}
    echo "$USERNAME_CUSTOM_PASS" | sudo -S rm -rf /tmp/*

    # remove npm
    echo "$USERNAME_CUSTOM_PASS" | sudo -S rm -rf /opt/nodejs/bin/npm
    echo "$USERNAME_CUSTOM_PASS" | sudo -S rm -rf /opt/nodejs/lib/node_modules/npm/

    # remove os dependencies
    echo "$USERNAME_CUSTOM_PASS" | sudo -S apt-get purge -y --auto-remove apt-transport-https build-essential bsdtar bzip2 ca-certificates curl git python
    echo "$USERNAME_CUSTOM_PASS" | sudo -S apt-get -y autoremove
    echo "$USERNAME_CUSTOM_PASS" | sudo -S apt-get -y clean
    echo "$USERNAME_CUSTOM_PASS" | sudo -S apt-get -y autoclean
    echo "$USERNAME_CUSTOM_PASS" | sudo -S rm -rf /var/lib/apt/lists/*
else
    # Clean out docs
    rm -rf /usr/share/{doc,doc-base,man,locale,zoneinfo}
    # Clean out package management dirs
    rm -rf /var/lib/{cache,log}
    # remove app source
    rm -rf "$APP_SOURCE_DIR"
    # remove meteor
    rm -rf /usr/local/bin/meteor
    rm -rf /root/.meteor
    # clean additional files created outside the source tree
    rm -rf /root/{.npm,.cache,.config,.cordova,.local}
    rm -rf /tmp/*
    # remove npm
    rm -rf /opt/nodejs/bin/npm
    rm -rf /opt/nodejs/lib/node_modules/npm/
    # remove os dependencies
    apt-get purge -y --auto-remove apt-transport-https build-essential bsdtar bzip2 ca-certificates curl git python
    apt-get -y autoremove
    apt-get -y clean
    apt-get -y autoclean
    rm -rf /var/lib/apt/lists/*
fi