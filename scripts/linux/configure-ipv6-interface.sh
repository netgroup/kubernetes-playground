#!/bin/sh

echo "Configuring the IPv6 interface"

IPV6_ADDRESS="$1"
IPV6_NETMASK="$2"
DEVICE="$3"
NET_CONFIG_PATH="/etc/network/interfaces"

echo "Adding $IPV6_ADDRESS to $DEVICE"

{
    echo "auto $DEVICE"
    echo "iface $DEVICE inet6 static"
    echo "  address $IPV6_ADDRESS"
    echo "  netmask $IPV6_NETMASK"
} >>"$NET_CONFIG_PATH"

echo "Restarting Network"
systemctl restart networking

echo "Getting all the IP addresses: $(ip -o addr show scope global)"

modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
