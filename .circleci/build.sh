#!/bin/bash

set -e

IMAGE_NAME=${DOCKER_IMAGE_NAME:-"pawlowskiadrian/meteor-launchpad"}


# Master branch versioned deployment (only runs when a version number git tag exists - syntax: "v1.2.3")
if [[ "$CIRCLE_BRANCH" == "master" ]]; then
  # build the latest
  docker build -f dev.dockerfile -t "$IMAGE_NAME":devbuild .
  docker build -t "$IMAGE_NAME":latest .
else
  echo "Not in a deployment branch. Skipping image deployment."
fi

if [[ "$CIRCLE_BRANCH" == "dev" ]]; then
  # build the latest
  echo "Deployment, development branch, building :devbuild only."
  docker build -f dev.dockerfile -t "$IMAGE_NAME":devbuild .
fi