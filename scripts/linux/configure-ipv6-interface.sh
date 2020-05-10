#!/bin/sh

echo "Configuring the IPv6 interface"

IPV6_ADDRESS="$1"
IPV6_NETMASK="$2"
DEVICE="$3"
UUID="$4"

echo "Current NetworkManager UUID $UUID assigned to $DEVICE"

echo "Adding $IPV6_ADDRESS to $DEVICE"
nmcli con mod "$UUID" ipv6.address "$IPV6_ADDRESS/$IPV6_NETMASK" ipv6.method manual

echo "Restarting NetworkManager"
systemctl restart network

echo "Getting all the IP addresses: $(ip -o addr show scope global)"
