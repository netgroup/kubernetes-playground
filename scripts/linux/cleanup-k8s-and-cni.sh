#!/bin/sh

#this script is useful to manually clean up the kubernetes, cni plugin, and
#networking environments, so that the installation of kubernetes and cni plugin
#can be repeated multiple times

#usage:
# cleanup-k8s-and-cni.sh

#clean up kubernetes control information and cni settings in all nodes

sudo kubeadm reset -f
KUBE_CONFIG_PATH="$HOME/.kube/config"
[ -d "$KUBE_CONFIG_PATH" ] && sudo rm "$KUBE_CONFIG_PATH"
KUBE_CONFIG_PATH="/home/vagrant/.kube/config"
[ -d "$KUBE_CONFIG_PATH" ] && rm -rf "$KUBE_CONFIG_PATH"
unset KUBE_CONFIG_VAGRANT_PATH
sudo rm /root/.kube/config
sudo rm -rf /etc/cni/net.d

#clean up iptables

sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -F
sudo iptables -X
