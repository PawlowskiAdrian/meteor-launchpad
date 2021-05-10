#!/bin/bash
if [ -f $APP_SOURCE_DIR/launchpad.conf ]; then
  source <(grep USERNAME_CUSTOM_PASS $APP_SOURCE_DIR/launchpad.conf)
  source <(grep USERNAME_CUSTOM_NAME $APP_SOURCE_DIR/launchpad.conf)
fi

if [ $USERNAME_CUSTOM_NAME ]; then
    if [ $(id -u) -eq 0 ]; then
        egrep "^$USERNAME_CUSTOM_NAME" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
            echo "$USERNAME_CUSTOM_NAME exists!"
            exit 1
        else
            if ! [ $USERNAME_CUSTOM_PASS ]; then
                echo "USERNAME_CUSTOM_PASS not specified, using: password"
                USERNAME_CUSTOM_PASS=$(echo "password")
            fi
            pass=$(perl -e 'print crypt($ARGV[0],"passwordSecret")' $USERNAME_CUSTOM_PASS)
            useradd -m -p "$pass" "$USERNAME_CUSTOM_NAME"
            if [ $? -eq 0 ] && echo "User: $USERNAME_CUSTOM_NAME, has been added to system." || echo "Failed to add a user!"
            usermod -aG sudo "$USERNAME_CUSTOM_NAME"
            if [ $? -eq 0 ] && echo "User: $USERNAME_CUSTOM_NAME, has been added to sudo group." || echo "Failed to add user to sudoers!"
        fi
    else
        echo "Only root may add a user to the system!"
        exit 2
    fi
fi
