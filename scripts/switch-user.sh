#!/bin/bash
if [ $USERNAME_CUSTOM_NAME ]; then
    su $USERNAME_CUSTOM_NAME
    echo "Proceeding as: $(whoami)."
    cd
    echo $USERNAME_CUSTOM_PASS | sudo -S chmod -R 750 $BUILD_SCRIPTS_DIR
else
    echo "USERNAME_CUSTOM_NAME has not been specified! Proceeding as: $(whoami)."
    exit 1
fi
