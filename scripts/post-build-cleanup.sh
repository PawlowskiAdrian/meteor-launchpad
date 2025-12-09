#!/bin/bash
set -e

printf "\n[-] Performing final cleanup...\n\n"

# get out of the src dir, so we can delete it
cd "$APP_BUNDLE_DIR"

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

# ============================================
# Remove OS dependencies (ignore errors for packages not installed)
# ============================================
apt-get purge -y --auto-remove \
    apt-transport-https \
    build-essential \
    bzip2 \
    ca-certificates \
    curl \
    git \
    python3 \
    cmake \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    libffi-dev \
    libreadline-dev \
    libsqlite3-dev \
    libbz2-dev \
    wget \
    2>/dev/null || true

apt-get -y autoremove || true
apt-get -y clean || true
apt-get -y autoclean || true
rm -rf /var/lib/apt/lists/*

# ============================================
# Remove Python 2 (built from source)
# ============================================
rm -rf /usr/local/bin/python2*
rm -rf /usr/local/lib/python2*
rm -rf /usr/bin/python2*
rm -rf /usr/bin/python

printf "\n[-] Cleanup complete!\n\n"