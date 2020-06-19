#!/bin/bash

docker run -t \
    -v "$(pwd)":/kubernetes-playground:ro \
    garethr/kubeval:0.14.0 \
    --strict -d /kubernetes-playground/kubernetes || exit 1

docker run --rm -it \
    -v "$(pwd)":/workspace \
    -w="/workspace" \
    -e ACTIONS_RUNNER_DEBUG=true \
    -e DEFAULT_WORKSPACE=/workspace \
    -e DISABLE_ERRORS=false \
    -e LINTER_RULES_PATH=. \
    -e MULTI_STATUS=false \
    -e RUN_LOCAL=true \
    -e VALIDATE_ALL_CODEBASE=true \
    ghcr.io/github/super-linter:v3.10.0 || exit 1

inspec check --chef-license=accept test/inspec/kubernetes-playground
