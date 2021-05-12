FROM debian:jessie
LABEL author="Jeremy Shimko <jeremy.shimko@gmail.com>, Adrian Pawlowski <petroniusz2008@gmail.com>"

RUN groupadd -r node && useradd -m -g node node
RUN usermod -aG staff node
RUN usermod -aG node root

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

# Define all --build-arg options
# ONBUILD ARG USERNAME_CUSTOM_NAME
# ONBUILD ENV USERNAME_CUSTOM_NAME ${USERNAME_CUSTOM_NAME:-joda}

# ONBUILD ARG USERNAME_CUSTOM_PASS
# ONBUILD ENV USERNAME_CUSTOM_PASS $USERNAME_CUSTOM_PASS

# ONBUILD RUN groupadd -r $USERNAME_CUSTOM_NAME && useradd -r -g $USERNAME_CUSTOM_NAME $USERNAME_CUSTOM_NAME
# ONBUILD USER $USERNAME_CUSTOM_NAME
# ONBUILD RUN echo -e "$USERNAME_CUSTOM_PASS\n$USERNAME_CUSTOM_PASS" | passwd $USERNAME_CUSTOM_NAME

ONBUILD ARG APT_GET_INSTALL
ONBUILD ENV APT_GET_INSTALL $APT_GET_INSTALL

ONBUILD ARG METEOR_VERSION_CUSTOM
ONBUILD ENV METEOR_VERSION_CUSTOM $METEOR_VERSION_CUSTOM

ONBUILD ARG NODE_VERSION
ONBUILD ENV NODE_VERSION ${NODE_VERSION:-14.16.1}

ONBUILD ARG NPM_TOKEN
ONBUILD ENV NPM_TOKEN $NPM_TOKEN

ONBUILD ARG INSTALL_MONGO
ONBUILD ENV INSTALL_MONGO ${INSTALL_MONGO:-false}

ONBUILD ARG INSTALL_PHANTOMJS
ONBUILD ENV INSTALL_PHANTOMJS ${INSTALL_PHANTOMJS:-false}

ONBUILD ARG INSTALL_GRAPHICSMAGICK
ONBUILD ENV INSTALL_GRAPHICSMAGICK ${INSTALL_GRAPHICSMAGICK:-false}

# Node flags for the Meteor build tool
ONBUILD ARG TOOL_NODE_FLAGS
ONBUILD ENV TOOL_NODE_FLAGS $TOOL_NODE_FLAGS

# copy the app to the container
ONBUILD COPY . $APP_SOURCE_DIR
ONBUILD RUN printf "\n[-] Source files copied to ${APP_SOURCE_DIR}\n\n"

# install all dependencies, phantom, graphicsmagick
ONBUILD RUN cd $APP_SOURCE_DIR && \
  $BUILD_SCRIPTS_DIR/install-deps.sh && \
  $BUILD_SCRIPTS_DIR/post-install-cleanup.sh && \
  $BUILD_SCRIPTS_DIR/install-phantom.sh && \
  $BUILD_SCRIPTS_DIR/install-graphicsmagick.sh

# add and switch user if specified
# ONBUILD RUN bash $BUILD_SCRIPTS_DIR/add-user.sh
# ONBUILD USER ${USERNAME_CUSTOM_NAME:-root}
# ONBUILD RUN bash $BUILD_SCRIPTS_DIR/switch-user.sh

# install mongo, node, meteor binaries
ONBUILD RUN cd $APP_SOURCE_DIR && \
  $BUILD_SCRIPTS_DIR/install-node.sh && \
  $BUILD_SCRIPTS_DIR/install-mongo.sh && \
  $BUILD_SCRIPTS_DIR/install-meteor.sh

# install all build app, clean up
ONBUILD RUN cd $APP_SOURCE_DIR && \
  $BUILD_SCRIPTS_DIR/build-meteor.sh && \
  $BUILD_SCRIPTS_DIR/post-build-cleanup.sh

# Default values for Meteor environment variables
ENV ROOT_URL http://localhost
ENV MONGO_URL mongodb://127.0.0.1:27017/meteor
ENV PORT 3000
ENV USERNAME_CUSTOM_NAME $USERNAME_CUSTOM_NAME

EXPOSE 3000

WORKDIR $APP_BUNDLE_DIR/bundle

# start the app
ENTRYPOINT ["./entrypoint.sh"]
CMD ["node", "main.js"]
