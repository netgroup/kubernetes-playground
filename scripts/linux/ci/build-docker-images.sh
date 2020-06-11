#!/bin/bash

set -e
set -o pipefail

INITIAL_PWD="$(pwd)"
echo "Current working directory: $INITIAL_PWD"

cd ansible || exit 1
ansible-lint -v kubernetes.yml openssl-self-signed-certificate.yml
echo "Setting the working directory back to $INITIAL_PWD"
cd "$INITIAL_PWD" || exit 1

cd docker/kites/net-tests || exit 1
docker build --target final -t kitesproject/net-test .
docker build --target dev -t kitesproject/net-test:latest-dev .
echo "Setting the working directory back to $INITIAL_PWD"
cd "$INITIAL_PWD" || exit 1

cd docker/ansible || exit 1
docker build -t ferrarimarco/kubernetes-playground-ansible .
echo "Setting the working directory back to $INITIAL_PWD"
cd "$INITIAL_PWD" || exit 1
