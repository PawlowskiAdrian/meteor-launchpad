FROM debian:stable

LABEL author="Jeremy Shimko <jeremy.shimko@gmail.com>, Adrian Pawlowski <petroniusz2008@gmail.com>"

ARG DEBIAN_FRONTEND=noninteractive

RUN groupadd -r node && useradd -m -g node node

ENV METEOR_ALLOW_SUPERUSER=true
# Gosu
ENV GOSU_VERSION=1.10
# MongoDB
ENV MONGO_VERSION=4.4.5
ENV MONGO_MAJOR=4.4
ENV MONGO_PACKAGE=mongodb-org
# PhantomJS
ENV PHANTOM_VERSION=2.1.1
# Build directories
ENV APP_SOURCE_DIR=/opt/meteor/src
ENV APP_BUNDLE_DIR=/opt/meteor/dist
ENV BUILD_SCRIPTS_DIR=/opt/build_scripts

# Add entrypoint and build scripts
COPY scripts $BUILD_SCRIPTS_DIR
RUN chmod -R 750 $BUILD_SCRIPTS_DIR

# ============================================
# ONBUILD: Declare build arguments
# ============================================
ONBUILD ARG APT_GET_INSTALL
ONBUILD ENV APT_GET_INSTALL=$APT_GET_INSTALL

ONBUILD ARG METEOR_VERSION_CUSTOM
ONBUILD ENV METEOR_VERSION_CUSTOM=$METEOR_VERSION_CUSTOM

ONBUILD ARG NODE_VERSION
ONBUILD ENV NODE_VERSION=${NODE_VERSION:-14.17.5}

ONBUILD ARG NPM_TOKEN
ONBUILD ENV NPM_TOKEN=$NPM_TOKEN

ONBUILD ARG INSTALL_MONGO
ONBUILD ENV INSTALL_MONGO=${INSTALL_MONGO:-false}

ONBUILD ARG INSTALL_PHANTOMJS
ONBUILD ENV INSTALL_PHANTOMJS=${INSTALL_PHANTOMJS:-false}

ONBUILD ARG INSTALL_GRAPHICSMAGICK
ONBUILD ENV INSTALL_GRAPHICSMAGICK=${INSTALL_GRAPHICSMAGICK:-false}

ONBUILD ARG TOOL_NODE_FLAGS
ONBUILD ENV TOOL_NODE_FLAGS=$TOOL_NODE_FLAGS

# ============================================
# ONBUILD STEP 1: Install system dependencies FIRST
# (includes Python 2.7 build for node-gyp)
# ============================================
ONBUILD RUN printf "\n[-] Installing system dependencies...\n\n" && \
    $BUILD_SCRIPTS_DIR/install-deps.sh && \
    $BUILD_SCRIPTS_DIR/post-install-cleanup.sh

# ============================================
# ONBUILD STEP 2: Install Node.js + configure node-gyp
# ============================================
ONBUILD RUN printf "\n[-] Installing Node.js and configuring node-gyp...\n\n" && \
    $BUILD_SCRIPTS_DIR/install-node.sh && \
    npm install -g node-gyp@latest && \
    ln -sf $(which node) /usr/local/bin/nodejs

# ============================================
# ONBUILD STEP 3: Install optional tools
# ============================================
ONBUILD RUN printf "\n[-] Installing optional tools...\n\n" && \
    $BUILD_SCRIPTS_DIR/install-phantom.sh && \
    $BUILD_SCRIPTS_DIR/install-graphicsmagick.sh

# ============================================
# ONBUILD STEP 4: Copy ONLY .meteor/release file
# ============================================
ONBUILD COPY .meteor/release $APP_SOURCE_DIR/.meteor/release

# ============================================
# ONBUILD STEP 5: Install Meteor + MongoDB
# ============================================
ONBUILD RUN printf "\n[-] Installing Meteor and MongoDB...\n\n" && \
    cd $APP_SOURCE_DIR && \
    $BUILD_SCRIPTS_DIR/install-meteor.sh && \
    $BUILD_SCRIPTS_DIR/install-mongo.sh

# ============================================
# ONBUILD STEP 6: Copy ONLY package files
# ============================================
ONBUILD COPY package*.json $APP_SOURCE_DIR/

# ============================================
# ONBUILD STEP 7: Install npm dependencies
# Ensure Python 2.7 is used for native module builds
# ============================================
ONBUILD RUN printf "\n[-] Installing npm dependencies...\n\n" && \
    cd $APP_SOURCE_DIR && \
    npm config set python /usr/local/bin/python2.7 && \
    meteor npm install

# ============================================
# ONBUILD STEP 8: Copy ALL source code
# ============================================
ONBUILD COPY . $APP_SOURCE_DIR

ONBUILD RUN printf "\n[-] Source files copied to ${APP_SOURCE_DIR}\n\n"

# ============================================
# ONBUILD STEP 9: Build application
# ============================================
ONBUILD RUN LD_LIBRARY_PATH=/usr/local/lib64/:$LD_LIBRARY_PATH && \
    export LD_LIBRARY_PATH && \
    cd $APP_SOURCE_DIR && \
    $BUILD_SCRIPTS_DIR/build-meteor.sh && \
    $BUILD_SCRIPTS_DIR/post-build-cleanup.sh

# ============================================
# Runtime configuration
# ============================================
ENV ROOT_URL=http://localhost
ENV MONGO_URL=mongodb://127.0.0.1:27017/meteor
ENV PORT=3000

EXPOSE 3000

WORKDIR $APP_BUNDLE_DIR/bundle

ENTRYPOINT ["./entrypoint.sh"]
CMD ["node", "main.js"]