#!/bin/bash
if [ -f $APP_SOURCE_DIR/launchpad.conf ]; then
  source <(grep USERNAME_CUSTOM_PASS $APP_SOURCE_DIR/launchpad.conf)
  source <(grep USERNAME_CUSTOM_NAME $APP_SOURCE_DIR/launchpad.conf)
  export $USERNAME_CUSTOM_NAME
  export $USERNAME_CUSTOM_PASS
fi

if [ $USERNAME_CUSTOM_NAME ]; then
    printf "\n[-] Adding custom user...\n\n"
    if [ $(id -u) -eq 0 ]; then
        egrep "^$USERNAME_CUSTOM_NAME" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
            printf "$USERNAME_CUSTOM_NAME exists!"
            exit 1
        else
            if ! [ $USERNAME_CUSTOM_PASS ]; then
                printf "USERNAME_CUSTOM_PASS not specified, using: password"
                USERNAME_CUSTOM_PASS=$(echo "password")
            fi
            pass=$(perl -e 'print crypt($ARGV[0],"passwordSecret")' $USERNAME_CUSTOM_PASS)
            useradd -m -p "$pass" "$USERNAME_CUSTOM_NAME"
            if [ $? -eq 0 ] && printf "User: $USERNAME_CUSTOM_NAME, has been added to system." || printf "Failed to add a user!"
            usermod -aG sudo "$USERNAME_CUSTOM_NAME"
            if [ $? -eq 0 ] && printf "User: $USERNAME_CUSTOM_NAME, has been added to sudo group." || printf "Failed to add user to sudoers!"
        fi
    else
        printf "Only root may add a user to the system!"
        exit 2
    fi
fi
