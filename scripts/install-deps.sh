#!/bin/bash
set -e

printf "\n[-] Installing system dependencies...\n\n"

apt-get update

# Install basic build tools
apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    build-essential \
    python3 \
    git \
    curl \
    wget \
    cmake \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    libffi-dev \
    libreadline-dev \
    libsqlite3-dev \
    libbz2-dev

# ============================================
# Build Python 2.7 from source for node-gyp
# (Required by old node-sass/node-gyp versions)
# ============================================
printf "\n[-] Building Python 2.7 from source...\n\n"

PYTHON2_VERSION="2.7.18"
cd /tmp
curl -L "https://www.python.org/ftp/python/${PYTHON2_VERSION}/Python-${PYTHON2_VERSION}.tgz" -o python2.tgz
tar -xzf python2.tgz
cd "Python-${PYTHON2_VERSION}"

./configure \
    --prefix=/usr/local \
    --enable-optimizations \
    --enable-shared \
    --with-ensurepip=install \
    LDFLAGS="-Wl,-rpath /usr/local/lib"

make -j$(nproc)
make altinstall

# Update library cache
ldconfig

# Create symlinks for python2 (required by old node-gyp)
ln -sf /usr/local/bin/python2.7 /usr/local/bin/python2
ln -sf /usr/local/bin/python2.7 /usr/bin/python2

# Create python symlink pointing to python3 (for modern tools)
ln -sf /usr/bin/python3 /usr/bin/python

# Cleanup Python build
cd /tmp && rm -rf Python-${PYTHON2_VERSION} python2.tgz

printf "\n[-] Python 2.7 installed at: $(python2 --version 2>&1)\n"
printf "[-] Python 3 available at: $(python3 --version)\n\n"

# ============================================
# Install libmongocrypt from source
# ============================================
printf "\n[-] Installing libmongocrypt from source...\n\n"

MONGOCRYPT_VERSION="1.8.2"
cd /tmp
curl -L "https://github.com/mongodb/libmongocrypt/archive/refs/tags/${MONGOCRYPT_VERSION}.tar.gz" -o libmongocrypt.tar.gz
tar -xzf libmongocrypt.tar.gz
cd "libmongocrypt-${MONGOCRYPT_VERSION}"

mkdir cmake-build && cd cmake-build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DBUILD_VERSION=${MONGOCRYPT_VERSION} \
      ..
make -j$(nproc)
make install
ldconfig

cd /tmp && rm -rf libmongocrypt*

# Install any additional dependencies from APT_GET_INSTALL
if [ -n "$APT_GET_INSTALL" ]; then
    printf "\n[-] Installing additional dependencies: $APT_GET_INSTALL\n\n"
    apt-get install -y --no-install-recommends $APT_GET_INSTALL
fi

printf "\n[-] System dependencies installed!\n\n"