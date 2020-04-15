#!/bin/sh

echo "Configuring the IPv6 interface"

IPV6_ADDRESS="$1"
CURRENT_IPV4_ADDRESS="$2"
IPV6_NETMASK="$3"
DEVICE="$4"
UUID="$5"

echo "Current IPv4 address $CURRENT_IPV4_ADDRESS assigned to $DEVICE"

echo "Current NetworkManager UUID $UUID assigned to $DEVICE"

echo "Adding $IPV6_ADDRESS to $DEVICE"
nmcli con mod "$UUID" ipv6.address "$IPV6_ADDRESS/$IPV6_NETMASK" ipv6.method manual

echo "Restarting NetworkManager"
systemctl restart network

echo "Getting all the IP addresses: $(ip -o addr show scope global)"
