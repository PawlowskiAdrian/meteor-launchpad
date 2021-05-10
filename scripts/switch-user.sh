#!/bin/bash
if [ $USERNAME_CUSTOM_NAME ]; then
    su $USERNAME_CUSTOM_NAME
    printf "Proceeding as: $(whoami).\n"
    echo $USERNAME_CUSTOM_PASS | sudo -S chmod -R 750 $BUILD_SCRIPTS_DIR
else
    printf "USERNAME_CUSTOM_NAME has not been specified! Proceeding as: $(whoami).\n"
    exit 1
fi
