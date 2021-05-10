#!/bin/bash
set -e

if [ "$USERNAME_CUSTOM_NAME" ]; then
    su - "$USERNAME_CUSTOM_NAME"
    printf "[INFO] Proceeding as: %s.\n" "$(whoami)"
    echo "$USERNAME_CUSTOM_PASS" | sudo -S chmod -R 750 "$BUILD_SCRIPTS_DIR"
else
    printf "[INFO] USERNAME_CUSTOM_NAME has not been specified! Proceeding as: %s.\n" "$(whoami)"
fi
