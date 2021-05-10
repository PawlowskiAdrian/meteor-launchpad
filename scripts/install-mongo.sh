#!/bin/bash

set -e

if [ -f "$APP_SOURCE_DIR"/launchpad.conf ]; then
  source <(grep INSTALL_MONGO $APP_SOURCE_DIR/launchpad.conf)
fi

if [ "$INSTALL_MONGO" = true ]; then
  printf "\n[-] Installing MongoDB %s...\n\n" "${MONGO_VERSION}"

	if [ "$USERNAME_CUSTOM_NAME" ]; then
    echo "$USERNAME_CUSTOM_PASS" | sudo -S apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 0C49F3730359A14518585931BC711F9BA15703C6
    echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/$MONGO_MAJOR main" > /etc/apt/sources.list.d/mongodb-org.list
    echo "$USERNAME_CUSTOM_PASS" | sudo -S apt-get install -y \
      "${MONGO_PACKAGE}"="$MONGO_VERSION" \
      "${MONGO_PACKAGE}"-server="$MONGO_VERSION" \
      "${MONGO_PACKAGE}"-shell="$MONGO_VERSION" \
      "${MONGO_PACKAGE}"-mongos="$MONGO_VERSION" \
      "${MONGO_PACKAGE}"-tools="$MONGO_VERSION"
    echo "$USERNAME_CUSTOM_PASS" | sudo -S mkdir -p /data/{db,configdb}
    echo "$USERNAME_CUSTOM_PASS" | sudo -S chown -R mongodb:mongodb /data/{db,configdb}
    echo "$USERNAME_CUSTOM_PASS" | sudo -S rm -rf /var/lib/apt/lists/*
    echo "$USERNAME_CUSTOM_PASS" | sudo -S rm -rf /var/lib/mongodb
    echo "$USERNAME_CUSTOM_PASS" | sudo -S mv /etc/mongod.conf /etc/mongod.conf.orig
  else
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 0C49F3730359A14518585931BC711F9BA15703C6
    echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/$MONGO_MAJOR main" > /etc/apt/sources.list.d/mongodb-org.list
    apt-get install -y \
      "${MONGO_PACKAGE}"="$MONGO_VERSION" \
      "${MONGO_PACKAGE}"-server="$MONGO_VERSION" \
      "${MONGO_PACKAGE}"-shell="$MONGO_VERSION" \
      "${MONGO_PACKAGE}"-mongos="$MONGO_VERSION" \
      "${MONGO_PACKAGE}"-tools="$MONGO_VERSION"
    mkdir -p /data/{db,configdb}
    chown -R mongodb:mongodb /data/{db,configdb}
    rm -rf /var/lib/apt/lists/*
    rm -rf /var/lib/mongodb
    mv /etc/mongod.conf /etc/mongod.conf.orig
  fi
fi
