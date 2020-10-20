#!/bin/sh

set -e

SSH_HOST="$1"

echo "Setting environment variables for InSpec to connect to $SSH_HOST via ssh..."

SSH_CONFIG_FOR_HOST="$(vagrant ssh-config "$SSH_HOST")"
INSPEC_SSH_USER="$(echo "$SSH_CONFIG_FOR_HOST" | grep -m1 -oP '(?<=User ).*')"
INSPEC_SSH_HOST="$(echo "$SSH_CONFIG_FOR_HOST" | grep -m1 -oP '(?<=HostName ).*')"
INSPEC_SSH_PRIVATE_KEY_PATH="$(echo "$SSH_CONFIG_FOR_HOST" | grep -m1 -oP '(?<=IdentityFile ).*')"
INSPEC_SSH_PORT="$(echo "$SSH_CONFIG_FOR_HOST" | grep -m1 -oP '(?<=Port ).*')"

echo "Configuration variables for $SSH_HOST:
INSPEC_SSH_USER=$INSPEC_SSH_USER, \
INSPEC_SSH_HOST=$INSPEC_SSH_HOST, \
INSPEC_SSH_PRIVATE_KEY_PATH=$INSPEC_SSH_PRIVATE_KEY_PATH, \
INSPEC_SSH_PORT=$INSPEC_SSH_PORT"

echo "Running inspec against $SSH_HOST ($INSPEC_SSH_USER@$INSPEC_SSH_HOST:$INSPEC_SSH_PORT)"
inspec exec --chef-license=accept test/inspec/kubernetes-playground \
    --diagnose \
    --log-level=debug \
    -t ssh://"$INSPEC_SSH_USER"@"$INSPEC_SSH_HOST" \
    -i "$INSPEC_SSH_PRIVATE_KEY_PATH" \
    -p "$INSPEC_SSH_PORT"

unset SSH_HOST

set +e
