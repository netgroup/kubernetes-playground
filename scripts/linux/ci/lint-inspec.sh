#!/bin/sh

DOCKER_FLAGS=
if [ -t 0 ]; then
  DOCKER_FLAGS=-it
fi

docker run \
    ${DOCKER_FLAGS} \
    --rm \
    -v "$(pwd)":/share \
    chef/inspec:4.23.15 \
    check --chef-license=accept test/inspec/kubernetes-playground
