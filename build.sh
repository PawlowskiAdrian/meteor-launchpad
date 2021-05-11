#!/bin/bash

set -e

IMAGE_NAME=${1:-"pawlowskiadrian/meteor-launchpad"}

printf "\n[-] Building %s...\n\n" "${IMAGE_NAME}"

docker build -f dev.dockerfile -t "$IMAGE_NAME":devbuild .
docker build -t "$IMAGE_NAME":latest .
