#!/bin/sh

echo "Initializing machine id..."
systemd-machine-id-setup
echo "machine id set to: $(cat /etc/machine-id)"
