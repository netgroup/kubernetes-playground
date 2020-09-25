#!/bin/sh

docker run --rm -it \
    -v "$(pwd)":/workspace:ro \
    -w="/workspace" \
    -e ACTIONS_RUNNER_DEBUG=true \
    -e DEFAULT_WORKSPACE=/workspace \
    -e DISABLE_ERRORS=false \
    -e ERROR_ON_MISSING_EXEC_BIT=true \
    -e LINTER_RULES_PATH=. \
    -e MULTI_STATUS=false \
    -e RUN_LOCAL=true \
    -e VALIDATE_ALL_CODEBASE=true \
    ghcr.io/github/super-linter:v3.11.0 || exit 1

inspec check --chef-license=accept test/inspec/kubernetes-playground
