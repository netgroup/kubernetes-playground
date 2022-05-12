#!/bin/sh

docker run \
  -it \
  --rm \
  -v "$(pwd)":/share \
  chef/inspec:4.23.15 \
  check --chef-license=accept test/inspec/kubernetes-playground
