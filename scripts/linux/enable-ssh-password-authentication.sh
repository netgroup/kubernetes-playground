#!/bin/sh

# Stop the execution on errors.
set -e

SSH_CONFIG_FILE_PATH=/etc/ssh/sshd_config
if [ -f "$SSH_CONFIG_FILE_PATH" ]; then
    echo "Checking if password authentication is enabled for SSH connections in: $SSH_CONFIG_FILE_PATH"
    SSHD_CONFIG_UPDATED="false"
    if grep -q "^PasswordAuthentication no" "$SSH_CONFIG_FILE_PATH"; then
        echo "Password authentication for SSH connections is disabled. Enabling it..."
        sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" "$SSH_CONFIG_FILE_PATH"
        SSHD_CONFIG_UPDATED="true"
    elif ! grep -q "^PasswordAuthentication" "$SSH_CONFIG_FILE_PATH"; then
        echo "Password authentication was not configured. Enabling password authentication for SSH connections..."
        sed -i -e "\$aPasswordAuthentication yes" "$SSH_CONFIG_FILE_PATH"
        SSHD_CONFIG_UPDATED="true"
    fi

    if [ "$SSHD_CONFIG_UPDATED" = "true" ]; then
        echo "Restarting the sshd service to get the updated configuration..."
        systemctl restart sshd
    else
        echo "The SSH daemon already accepts password authentication."
    fi

    unset SSHD_CONFIG_UPDATED
else
    echo "File $SSH_CONFIG_FILE_PATH not found."
    exit 1
fi

unset SSH_CONFIG_FILE_PATH

VAGRANT_USER_NAME="vagrant"
VAGRANT_USER_PASSWORD="vagrant"
echo "Ensure the $VAGRANT_USER_NAME user has a known password (user: $VAGRANT_USER_NAME, password: $VAGRANT_USER_PASSWORD"
usermod --password "$(openssl passwd -1 "$VAGRANT_USER_PASSWORD")" "$VAGRANT_USER_NAME"
unset VAGRANT_USER_NAME
unset VAGRANT_USER_PASSWORD

# Re-enable the default behaviour, because we don't know if other scripts are
# aware of this change.
set +e
