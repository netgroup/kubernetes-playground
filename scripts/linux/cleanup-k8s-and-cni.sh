#!/bin/sh

#this script is useful to manually clean up the kubernetes, cni plugin, and
#networking environments, so that the installation of kubernetes and cni plugin
#can be repeated multiple times

#usage (as vagrant user):
# sudo cleanup-k8s-and-cni.sh

#usage (as root)
# cleanup-k8s-and-cni.sh

#clean up kubernetes control information and cni settings in all nodes

KUBE_CONFIG_PATH="$HOME/.kube"

# If we're on a master, let's drain and remove all the workers first.
# Note that if there are multiple masters, we should provide a mechanism to
# avoid stepping on another master's toes when draining and removing nodes.
if [ -d "$KUBE_CONFIG_PATH" ] && kubectl get nodes -l node-role.kubernetes.io/master= -o name | grep -qs "$(hostname)"; then
    echo "Draining and deleting nodes from the cluster"
    kubectl get no -o name | while IFS= read -r line; do
        echo "Draining $line"
        kubectl drain "$line" --delete-local-data --force --ignore-daemonsets

        echo "Deleting $line from the cluster"
        kubectl delete "$line"
    done
fi

kubeadm reset -f

[ -d "$KUBE_CONFIG_PATH" ] && rm -rf "$KUBE_CONFIG_PATH"
echo "Deleted $KUBE_CONFIG_PATH"
unset KUBE_CONFIG_PATH

KUBE_CONFIG_VAGRANT_PATH="/home/vagrant/.kube"
[ -d "$KUBE_CONFIG_VAGRANT_PATH" ] && rm -rf "$KUBE_CONFIG_VAGRANT_PATH"
echo "Deleted $KUBE_CONFIG_PATH"
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

#reboot
reboot
