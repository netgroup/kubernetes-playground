#!/bin/sh

#this script is useful to manually clean up the kubernetes, cni plugin, and
#networking environments, so that the installation of kubernetes and cni plugin
#can be repeated multiple times

#usage (as vagrant user):
# sudo cleanup-k8s-and-cni.sh

#usage (as root)
# cleanup-k8s-and-cni.sh

#clean up kubernetes control information and cni settings in all nodes

kubeadm reset -f
KUBE_CONFIG_PATH="$HOME/.kube/config"
[ -d "$KUBE_CONFIG_PATH" ] && rm -rf "$KUBE_CONFIG_PATH"
echo "Manually cleaned up $KUBE_CONFIG_PATH"
KUBE_CONFIG_PATH="/home/vagrant/.kube/config"
[ -d "$KUBE_CONFIG_PATH" ] && rm -rf "$KUBE_CONFIG_PATH"
echo "Manually cleaned up $KUBE_CONFIG_PATH"
unset KUBE_CONFIG_VAGRANT_PATH
rm -rf /etc/cni/net.d

#clean up iptables

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
