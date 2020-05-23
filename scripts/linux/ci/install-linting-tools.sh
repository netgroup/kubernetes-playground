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

pip install -r requirements.txt

echo "Gimme version: $(gimme --version)"
echo "Gimme help: $(gimme --help)"
echo "Installable go versions: $(gimme --known)"
GIMME_GO_VERSION="1.14.x"
#GIMME_OS=linux
#GIMME_ARCH=amd64
echo "Installing Go $GIMME_GO_VERSION"
gimme "$GO_VERSION"

echo "Go version: $(go --version)"

# shellcheck source=/dev/null
. "$HOME"/.gimme/envs/go1.4.env

GO111MODULE=on go get mvdan.cc/sh/v3/cmd/shfmt

npm install
