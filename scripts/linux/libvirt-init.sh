#!/bin/sh

echo "Running the libvirt 'first boot' script..."

echo "Current user: $(whoami)"

echo "Initializing machine id..."
systemd-machine-id-setup
echo "machine id set to: $(cat /etc/machine-id)"

echo "Restarting networking service..."
systemctl restart networking.service
