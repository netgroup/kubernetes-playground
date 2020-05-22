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

GO111MODULE=on go get mvdan.cc/sh/v3/cmd/shfmt

npm install
