#!/bin/sh

echo "Generating an env.yaml for the Travis CI environment..."

cat >env.yaml <<EOF
conf:
  playground_name: k8s-play
  vagrant_provider: libvirt
EOF
