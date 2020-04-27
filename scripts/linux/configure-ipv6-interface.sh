#!/bin/sh

echo "making IPv4 forwarding permanent"
grep -Fv net.ipv4.ip_forward /etc/sysctl.conf >/etc/sysctl.conf.mytmp
echo "net.ipv4.ip_forward=1" >>/etc/sysctl.conf.mytmp
mv /etc/sysctl.conf.mytmp /etc/sysctl.conf

echo "enabling iptables bridging for IPv4 traffic"
grep -Fv net.bridge.bridge-nf-call-iptables /etc/sysctl.conf >/etc/sysctl.conf.mytmp
echo "net.bridge.bridge-nf-call-iptables=1" >>/etc/sysctl.conf.mytmp
mv /etc/sysctl.conf.mytmp /etc/sysctl.conf

echo "enabling iptables bridging for IPv6 traffic"
grep -Fv net.bridge.bridge-nf-call-ip6tables /etc/sysctl.conf >/etc/sysctl.conf.mytmp
echo "net.bridge.bridge-nf-call-ip6tables=1" >>/etc/sysctl.conf.mytmp
mv /etc/sysctl.conf.mytmp /etc/sysctl.conf

echo "Configuring the IPv6 interface"

CURRENT_IPV4_ADDRESS="$2"
DEVICE="$(ip -o addr show scope global | grep "$CURRENT_IPV4_ADDRESS" | awk '{print $2}')"
echo "Current IPv4 address $CURRENT_IPV4_ADDRESS assigned to $DEVICE"

UUID="$(nmcli -g UUID,DEVICE con show | grep "$DEVICE" | awk -F ":" '{print $1}')"
echo "Current NetworkManager UUID $UUID assigned to $DEVICE"

IPV6_ADDRESS="$1"
IPV6_NETMASK="$3"
echo "Adding $IPV6_ADDRESS to $DEVICE"
nmcli con mod "$UUID" ipv6.address "$IPV6_ADDRESS/$IPV6_NETMASK" ipv6.method manual

echo "Restarting NetworkManager"
systemctl restart network

echo "Getting all the IP addresses: $(ip -o addr show scope global)"

modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
