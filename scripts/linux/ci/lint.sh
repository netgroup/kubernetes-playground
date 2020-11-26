#!/bin/sh

docker run --rm -it \
    -v "$(pwd)":/workspace \
    -w="/workspace" \
    -e DEFAULT_WORKSPACE=/workspace \
    -e DISABLE_ERRORS=false \
    -e ERROR_ON_MISSING_EXEC_BIT=true \
    -e LINTER_RULES_PATH=. \
    -e MULTI_STATUS=false \
    -e RUN_LOCAL=true \
    -e VALIDATE_ALL_CODEBASE=true \
    ghcr.io/github/super-linter:v3.13.5 || exit 1

inspec check --chef-license=accept test/inspec/kubernetes-playground
