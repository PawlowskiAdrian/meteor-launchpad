#!/bin/bash

set -e

printf "\n[-] Installing base OS dependencies...\n\n"

# install base dependencies

apt-get update

# ensure we can get an https apt source if redirected
# https://github.com/jshimko/meteor-launchpad/issues/50
apt-get install -y apt-transport-https ca-certificates

if [ -f "$APP_SOURCE_DIR"/launchpad.conf ]; then
  source <(grep APT_GET_INSTALL "$APP_SOURCE_DIR"/launchpad.conf)

  if [ "$APT_GET_INSTALL" ]; then
    printf "\n[-] Installing custom apt dependencies...\n\n"
    apt-get install -y "$APT_GET_INSTALL"
  fi
fi

apt-get update
apt-get install -y --no-install-recommends curl bzip2 libarchive-tools gpg-agent gpg dirmngr build-essential git wget chrpath apt-utils python3
apt-get install -y --no-install-recommends gnupg2

# install python 2

wget http://www.python.org/ftp/python/2.6.9/Python-2.6.9.tgz -P /tmp
mkdir -p /tmp/Python-2.6.9
tar -xzf /tmp/Python-2.6.9.tgz -C /tmp
cd /tmp/Python-2.6.9
./configure --prefix=/usr --enable-shared
make
make install
cd ~

# configure python alternatives

update-alternatives --install /usr/bin/python python /usr/bin/python2.6 20
update-alternatives --install /usr/bin/python python /usr/bin/python3 10

# install gosu

dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"

wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"
wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"

export GNUPGHOME="$(mktemp -d)"

gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu

# "$GNUPGHOME"
rm -r /usr/local/bin/gosu.asc

chmod +x /usr/local/bin/gosu

gosu nobody true

apt-get purge -y --auto-remove wget
