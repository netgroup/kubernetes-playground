#!/bin/bash

set -e
set -o pipefail

# - name: "YAMLlint"
# language: python
# python: "3.8"
# - name: "Markdownlint"
# language: node_js
# node_js: node

echo "Python path: $(command -v python)"
echo "Python version: $(python --version)"

echo "Python 3 path: $(command -v python3)"
echo "Python 3 version: $(python3 --version)"
echo "pip 3 path: $(command -v pip3)"
echo "pip 3 version: $(pip3 --version)"

pip3 install \
    setuptools \
    wheel

pip3 install -r requirements.txt

echo "Gimme version: $(gimme --version)"
GIMME_GO_VERSION="1.14.3"
GIMME_ARCH=amd64
GIMME_OS=linux
echo "Installing Go $GIMME_GO_VERSION ($GIMME_ARCH $GIMME_OS)"
eval "$(GIMME_GO_VERSION=$GIMME_GO_VERSION GIMME_ARCH=$GIMME_ARCH GIMME_OS=$GIMME_OS gimme)"
echo "Go version: $(go version)"

GO111MODULE=on go get mvdan.cc/sh/v3/cmd/shfmt

npm install
