#!/bin/bash
set -e

if [ -f "$APP_SOURCE_DIR"/launchpad.conf ]; then
  source <(grep USERNAME_CUSTOM_PASS "$APP_SOURCE_DIR"/launchpad.conf)
  source <(grep USERNAME_CUSTOM_NAME "$APP_SOURCE_DIR"/launchpad.conf)
fi

if [ "$USERNAME_CUSTOM_NAME" ]; then
    su - "$USERNAME_CUSTOM_NAME"
    printf "[INFO] Proceeding as: %s.\n" "$(whoami)"
    echo "$USERNAME_CUSTOM_PASS" | sudo -S chmod -R 750 "$BUILD_SCRIPTS_DIR"
else
    printf "[INFO] USERNAME_CUSTOM_NAME has not been specified! Proceeding as: %s.\n" "$(whoami)"
fi
