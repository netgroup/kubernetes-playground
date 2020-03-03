#!/bin/sh

#this script is useful to manually clean up the kubernetes, cni plugin, and
#networking environments, so that the installation of kubernetes and cni plugin
#can be repeated multiple times

#usage:
# cleanup-k8s-and-cni.sh PLAYGROUND_NAME
#example:
# cleanup-k8s-and-cni.sh k8s-play


#clean up kubernetes control information and cni settings in all nodes

sudo kubeadm reset -f
sudo rm "$HOME/.kube/config"
sudo rm /root/.kube/config
sudo rm -rf /etc/cni/net.d

sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -F
sudo iptables -X

PLAYGROUND_NAME="$1"
#PLAYGROUND_NAME="k8s-p9"

#clean up /etc/hosts
SCRIPT_NAME="manage-hosts.sh"
SCRIPT_PATH="/vagrant/scripts/linux"

MASTER_1="k8s-master-1"
MINION_1="k8s-minion-1"
MINION_2="k8s-minion-2"
MINION_3="k8s-minion-3"

$SCRIPT_PATH/$SCRIPT_NAME remove "$MASTER_1.$PLAYGROUND_NAME.local"
$SCRIPT_PATH/$SCRIPT_NAME remove "$MINION_1.$PLAYGROUND_NAME.local"
$SCRIPT_PATH/$SCRIPT_NAME remove "$MINION_2.$PLAYGROUND_NAME.local"
$SCRIPT_PATH/$SCRIPT_NAME remove "$MINION_3.$PLAYGROUND_NAME.local"

