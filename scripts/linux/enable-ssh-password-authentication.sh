#!/usr/bin/env sh

# Stop the execution on errors.
set -e

SSH_CONFIG_FILE_PATH=/etc/ssh/sshd_config
if [ -f "$SSH_CONFIG_FILE_PATH" ]; then
    echo "Enabling password authentication for SSH connections."
    SSHD_CONFIG_UPDATED=0
    if grep -q "^PasswordAuthentication no" "$SSH_CONFIG_FILE_PATH"; then
        echo "Password authentication for SSH connections is disabled. Enabling it..."
        sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" "$SSH_CONFIG_FILE_PATH"
        SSHD_CONFIG_UPDATED=1
    elif ! grep -q "^PasswordAuthentication"; then
        echo "Enabling password authentication for SSH connections..."
        sed -i -e "\$aPasswordAuthentication yes" "$SSH_CONFIG_FILE_PATH"
        SSHD_CONFIG_UPDATED=1
    fi

    if [ "$SSHD_CONFIG_UPDATED" = 1 ]; then
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

# Re-enable the default behaviour, because we don't know if other scripts are
# aware of this change.
set +e
