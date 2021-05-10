FROM debian:jessie
LABEL author="Jeremy Shimko <jeremy.shimko@gmail.com>, Adrian Pawlowski <petroniusz2008@gmail.com>"

RUN groupadd -r node && useradd -m -g node node

ENV DEV_BUILD true

# Customer user with sudo access
ENV USERNAME_CUSTOM_NAME debian

# Gosu
ENV GOSU_VERSION 1.10

# MongoDB
ENV MONGO_VERSION 4.4.5
ENV MONGO_MAJOR 4.4
ENV MONGO_PACKAGE mongodb-org

# PhantomJS
ENV PHANTOM_VERSION 2.1.1

# build directories
ENV APP_SOURCE_DIR /opt/meteor/src
ENV APP_BUNDLE_DIR /opt/meteor/dist
ENV BUILD_SCRIPTS_DIR /opt/build_scripts

# Add entrypoint and build scripts
COPY scripts $BUILD_SCRIPTS_DIR
RUN chmod -R 750 $BUILD_SCRIPTS_DIR

# define all --build-arg options
ONBUILD ARG APT_GET_INSTALL
ONBUILD ENV APT_GET_INSTALL $APT_GET_INSTALL

ONBUILD ARG METEOR_VERSION_CUSTOM
ONBUILD ENV METEOR_VERSION_CUSTOM $METEOR_VERSION_CUSTOM

ONBUILD ARG NODE_VERSION
ONBUILD ENV NODE_VERSION ${NODE_VERSION:-14.16.1}

ONBUILD ARG NPM_TOKEN
ONBUILD ENV NPM_TOKEN $NPM_TOKEN

ONBUILD ARG INSTALL_MONGO
ONBUILD ENV INSTALL_MONGO ${INSTALL_MONGO:-true}

ONBUILD ARG INSTALL_PHANTOMJS
ONBUILD ENV INSTALL_PHANTOMJS ${INSTALL_PHANTOMJS:-true}

ONBUILD ARG INSTALL_GRAPHICSMAGICK
ONBUILD ENV INSTALL_GRAPHICSMAGICK ${INSTALL_GRAPHICSMAGICK:-true}

# install base dependencies, build app, cleanup
ONBUILD RUN bash $BUILD_SCRIPTS_DIR/install-deps.sh && \
		bash $BUILD_SCRIPTS_DIR/post-install-cleanup.sh

# optionally install Mongo or Phantom at app build time
ONBUILD RUN bash $BUILD_SCRIPTS_DIR/install-phantom.sh
ONBUILD RUN bash $BUILD_SCRIPTS_DIR/install-mongo.sh
ONBUILD RUN bash $BUILD_SCRIPTS_DIR/install-graphicsmagick.sh

# Node flags for the Meteor build tool
ONBUILD ARG TOOL_NODE_FLAGS
ONBUILD ENV TOOL_NODE_FLAGS $TOOL_NODE_FLAGS

ONBUILD RUN bash $BUILD_SCRIPTS_DIR/install-node.sh
ONBUILD RUN bash $BUILD_SCRIPTS_DIR/install-meteor.sh
ONBUILD COPY . $APP_SOURCE_DIR
ONBUILD RUN bash $BUILD_SCRIPTS_DIR/build-meteor.sh

# Default values for Meteor environment variables
ENV ROOT_URL http://localhost
ENV MONGO_URL mongodb://127.0.0.1:27017/meteor
ENV PORT 3000

EXPOSE 3000

WORKDIR $APP_BUNDLE_DIR/bundle

# start the app
ENTRYPOINT ["./entrypoint.sh"]
CMD ["node", "main.js"]
