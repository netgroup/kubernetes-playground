#!/bin/bash

set -e
set -o pipefail

echo "Installing bundler and gems..."
gem install bundler
bundle install
