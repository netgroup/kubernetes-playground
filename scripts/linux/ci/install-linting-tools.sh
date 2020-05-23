#!/bin/sh

# - name: "YAMLlint"
# language: python
# python: "3.8"
# - name: "Markdownlint"
# language: node_js
# node_js: node
# - name: "shfmt"
# language: go
# go: "1.14.1"

pip3 install -r requirements.txt

echo "Gimme version: $(gimme --version)"
echo "Gimme help: $(gimme --help)"
echo "Installable go versions: $(gimme --known)"

GIMME_GO_VERSION="1.14.x"
GIMME_ARCH=amd64
GIMME_OS=linux
echo "Installing Go $GIMME_GO_VERSION ($GIMME_ARCH $GIMME_OS)"
eval "$(GIMME_GO_VERSION=$GIMME_GO_VERSION GIMME_ARCH=$GIMME_ARCH=amd64 GIMME_OS=$GIMME_OS gimme)"

echo "Go version: $(go --version)"

GO111MODULE=on go get mvdan.cc/sh/v3/cmd/shfmt

npm install
