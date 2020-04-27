#!/bin/sh

echo "Generating an env.yaml for the Travis CI environment..."

cat >env.yaml <<EOF
conf:
  vagrant_provider: libvirt
EOF
