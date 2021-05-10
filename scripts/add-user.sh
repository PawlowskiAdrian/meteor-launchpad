#!/bin/bash
set -e

if [ -f "$APP_SOURCE_DIR"/launchpad.conf ]; then
  source <(grep USERNAME_CUSTOM_PASS "$APP_SOURCE_DIR"/launchpad.conf)
  source <(grep USERNAME_CUSTOM_NAME "$APP_SOURCE_DIR"/launchpad.conf)
  export USERNAME_CUSTOM_NAME=$USERNAME_CUSTOM_NAME
  export USERNAME_CUSTOM_PASS=$USERNAME_CUSTOM_PASS
fi

if [ "$USERNAME_CUSTOM_NAME" ]; then
    printf "\n[-] Adding custom user: %s...\n\n" "$USERNAME_CUSTOM_NAME"
    if [ "$(id -u)" -eq 0 ]; then
        egrep "^$USERNAME_CUSTOM_NAME" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
            printf "[WARNING] %s exists!\n" "$USERNAME_CUSTOM_NAME"
            exit 0
        else
            if ! [ "$USERNAME_CUSTOM_PASS" ]; then
                printf "USERNAME_CUSTOM_PASS not specified, using: password\n"
                USERNAME_CUSTOM_PASS="password"
            fi
            pass=$(perl -e 'print crypt($ARGV[0],"passwordSecret")' "$USERNAME_CUSTOM_PASS")
            useradd -m -p "$pass" "$USERNAME_CUSTOM_NAME"
            [ $? -eq 0 ] && printf "[INFO] User: %s, has been added to system.\n" "$USERNAME_CUSTOM_NAME"
            ! [ $? -eq 0 ] && { printf "[ERROR] Failed to add a user!\nExiting..."; exit 1; }
            usermod -aG sudo "$USERNAME_CUSTOM_NAME"
            ! [ $? -eq 0 ] && { printf "[ERROR] Failed to add user to sudo group!\nExiting..."; exit 1; }
            usermod -aG staff "$USERNAME_CUSTOM_NAME"
            [ $? -eq 0 ] && printf "[INFO] User: %s, has been added to sudo and staff group.\n" "$USERNAME_CUSTOM_NAME" 
            ! [ $? -eq 0 ] && { printf "[ERROR] Failed to add user to staff group!\nExiting..."; exit 1; }
        fi
    else
        printf "[ERROR] Only root may add a user to the system!\n"
        exit 1
    fi
fi
