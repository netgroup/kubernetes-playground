#!/bin/sh

echo "Configuring the IPv6 interface"

CURRENT_IPV4_ADDRESS="$2"
DEVICE="$(ip -o addr show scope global | grep "$CURRENT_IPV4_ADDRESS" | awk '{print $2}')"
echo "Current IPv4 address $CURRENT_IPV4_ADDRESS assigned to $DEVICE"

IPV6_ADDRESS="$1"
IPV6_NETMASK="$3"
echo "Adding $IPV6_ADDRESS to $DEVICE"
ip -6 address add "$IPV6_ADDRESS/$IPV6_NETMASK" dev "$DEVICE"

echo "Getting all the IP addresses: $(ip -o addr show scope global)"
