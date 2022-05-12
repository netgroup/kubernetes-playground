#!/bin/sh

DOCKER_FLAGS=
if [ -t 0 ]; then
  DOCKER_FLAGS=-it
fi

docker run \
    ${DOCKER_FLAGS} \
    --rm \
    -v "$(pwd)":/workspace \
    -w="/workspace" \
    -e DEFAULT_WORKSPACE=/workspace \
    -e DISABLE_ERRORS=false \
    -e FILTER_REGEX_EXCLUDE="\.git" \
    -e ERROR_ON_MISSING_EXEC_BIT=true \
    -e LINTER_RULES_PATH=. \
    -e MULTI_STATUS=false \
    -e RUN_LOCAL=true \
    -e VALIDATE_ALL_CODEBASE=true \
    ghcr.io/github/super-linter:latest || exit 1
