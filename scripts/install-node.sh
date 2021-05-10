#!/bin/bash

set -e

if [ -f "$APP_SOURCE_DIR"/launchpad.conf ]; then
  source <(grep NODE_VERSION "$APP_SOURCE_DIR"/launchpad.conf)
  source <(grep USERNAME_CUSTOM_PASS "$APP_SOURCE_DIR"/launchpad.conf)
  source <(grep USERNAME_CUSTOM_NAME "$APP_SOURCE_DIR"/launchpad.conf)
fi

printf "\n[-] Installing Node %s...\n\n" "${NODE_VERSION}"

NODE_DIST=node-v${NODE_VERSION}-linux-x64

cd /tmp
curl -v -O -L http://nodejs.org/dist/v${NODE_VERSION}/${NODE_DIST}.tar.gz
tar xvzf "${NODE_DIST}".tar.gz
rm "${NODE_DIST}".tar.gz
if [ "$USERNAME_CUSTOM_NAME" != "root" ]; then
  echo "$USERNAME_CUSTOM_PASS" | sudo -S rm -rf /opt/nodejs
  echo "$USERNAME_CUSTOM_PASS" | sudo -S mv "${NODE_DIST}" /opt/nodejs
  echo "$USERNAME_CUSTOM_PASS" | sudo -S ln -sf /opt/nodejs/bin/node /usr/bin/node
  echo "$USERNAME_CUSTOM_PASS" | sudo -S ln -sf /opt/nodejs/bin/npm /usr/bin/npm
else
  rm -rf /opt/nodejs
  mv "${NODE_DIST}" /opt/nodejs
  ln -sf /opt/nodejs/bin/node /usr/bin/node
  ln -sf /opt/nodejs/bin/npm /usr/bin/npm
fi
