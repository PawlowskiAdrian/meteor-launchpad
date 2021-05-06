#!/bin/bash

## Required environment variables in your CircleCI dashboard
# (used to push to Docker Hub)
#
# $DOCKER_USER  - Docker Hub username
# $DOCKER_PASS  - Docker Hub password
# $DOCKER_EMAIL - Docker Hub email

## Optional environment variables
#
# $DOCKER_IMAGE_NAME - use to push the build to your own Docker Hub account (Default: jshimko/meteor-launchpad)

# check if we're on a version tagged commit
VERSION=$(git describe --tags | grep "^v[0-9]\+\.[0-9]\+\.[0-9]\+$")

# Master branch versioned deployment (only runs when a version number git tag exists - syntax: "v1.2.3")
if [[ "$CIRCLE_BRANCH" == "master" ]]; then

  # login to Docker Hub
  docker login -u $DOCKER_USER -p $DOCKER_PASS
  IMAGE_NAME=${DOCKER_IMAGE_NAME:-"pawlowskiadrian/meteor-launchpad"}

  if [[ "$VERSION" ]]; then

    # create a versioned tags
    docker tag $IMAGE_NAME:devbuild $IMAGE_NAME:$VERSION-devbuild
    docker tag $IMAGE_NAME:latest $IMAGE_NAME:$VERSION

    # push the builds with version TAG
    docker push $IMAGE_NAME:$VERSION-devbuild
    docker push $IMAGE_NAME:$VERSION
  else
    docker push $IMAGE_NAME:devbuild
    docker push $IMAGE_NAME:latest
    echo "On a deployment branch, but no version tag was found. Deployed latest, devbuild with no tagged version."
  fi
else
  echo "Not in a deployment branch. Skipping image deployment."
fi

if [[ "$CIRCLE_BRANCH" == "dev" ]]; then
  # build the latest
  echo "Development branch, pushing :devbuild only."

  # login to Docker Hub
  docker login -u $DOCKER_USER -p $DOCKER_PASS
  IMAGE_NAME=${DOCKER_IMAGE_NAME:-"pawlowskiadrian/meteor-launchpad"}

  if [[ "$VERSION" ]]; then

    # create a versioned tags
    docker tag $IMAGE_NAME:devbuild $IMAGE_NAME:$VERSION-devbuild

    # push the builds with version TAG
    docker push $IMAGE_NAME:$VERSION-devbuild
  else
    docker push $IMAGE_NAME:devbuild
    echo "On a deployment branch, but no version tag was found. Deployed devbuild with no tagged version."
  fi
fi