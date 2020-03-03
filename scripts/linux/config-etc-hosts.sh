#!/bin/sh

#this script is used to add the ip addresses of hosts in /etc/hosts
#it is needed by flannel, because it does not work if there is no information
#in /etc/hosts (it does not work even if DNS resolution is enabled)
#this script is invoked by bootstrap-kubernetes-minion.sh
#this script uses the script manage-hosts.sh

SCRIPT_NAME="manage-hosts.sh"
SCRIPT_PATH="/vagrant/scripts/linux"

PLAYGROUND_NAME="$1"
#PLAYGROUND_NAME="k8s-p9"

MASTER_1="k8s-master-1"
MINION_1="k8s-minion-1"
MINION_2="k8s-minion-2"
MINION_3="k8s-minion-3"

MASTER_1_IP="192.168.0.10"
MINION_1_IP="192.168.0.30"
MINION_2_IP="192.168.0.31"
MINION_3_IP="192.168.0.32"


$SCRIPT_PATH/$SCRIPT_NAME remove "$MASTER_1.$PLAYGROUND_NAME.local"
$SCRIPT_PATH/$SCRIPT_NAME remove "$MINION_1.$PLAYGROUND_NAME.local"
$SCRIPT_PATH/$SCRIPT_NAME remove "$MINION_2.$PLAYGROUND_NAME.local"
$SCRIPT_PATH/$SCRIPT_NAME remove "$MINION_3.$PLAYGROUND_NAME.local"

$SCRIPT_PATH/$SCRIPT_NAME add "$MASTER_1.$PLAYGROUND_NAME.local $MASTER_1_IP"
$SCRIPT_PATH/$SCRIPT_NAME add "$MINION_1.$PLAYGROUND_NAME.local $MINION_1_IP"
$SCRIPT_PATH/$SCRIPT_NAME add "$MINION_2.$PLAYGROUND_NAME.local $MINION_2_IP"
$SCRIPT_PATH/$SCRIPT_NAME add "$MINION_3.$PLAYGROUND_NAME.local $MINION_3_IP"


