#!/bin/bash
set -e

if [ -f "$APP_SOURCE_DIR"/launchpad.conf ]; then
    source <(grep NODE_VERSION "$APP_SOURCE_DIR"/launchpad.conf)
fi

printf "\n[-] Installing Node %s...\n\n" "${NODE_VERSION}"

NODE_DIST=node-v${NODE_VERSION}-linux-x64

cd /tmp
curl -v -O -L http://nodejs.org/dist/v${NODE_VERSION}/${NODE_DIST}.tar.gz
tar xvzf "${NODE_DIST}".tar.gz
rm "${NODE_DIST}".tar.gz
rm -rf /opt/nodejs
mv "${NODE_DIST}" /opt/nodejs

ln -sf /opt/nodejs/bin/node /usr/bin/node
ln -sf /opt/nodejs/bin/npm /usr/bin/npm

# ============================================
# Configure npm to use Python 2 for node-gyp
# (Required for old native modules like node-sass)
# ============================================
if [ -x "/usr/local/bin/python2.7" ]; then
    printf "\n[-] Configuring npm to use Python 2.7 for node-gyp...\n\n"
    /opt/nodejs/bin/npm config set python /usr/local/bin/python2.7
fi

printf "\n[-] Node.js installation complete!\n\n"