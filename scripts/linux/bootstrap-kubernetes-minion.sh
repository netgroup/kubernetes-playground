#!/bin/sh

set -e

master_address="$1"
token="$2"

# kubernetes_cluster_ip_cidr variable is currently unused
# but it is maintained as a comment to keep track that there is a parameter
# that it is passed to this script and because it could be needed
# for the configuration of specific networking plugins
#kubernetes_cluster_ip_cidr="$3"

network_plugin_id="$4"

if [ "$network_plugin_id" = 'weavenet' ]; then
    echo "Setup networking for weavenet"
elif [ "$network_plugin_id" = 'calico' ]; then
    echo "Setup networking for calico"
elif [ "$network_plugin_id" = 'flannel' ]; then
    echo "Setup networking for flannel"
fi

if [ "$network_plugin_id" != 'no-cni-plugin' ]; then
    echo "Initializing Kubernetes minion to join: $master_address and token: $token"
    kubeadm join "$master_address":6443 --token "$token" --discovery-token-unsafe-skip-ca-verification 2>&1 | tee /vagrant/kubeadm-init-worker.log
fi

set +e
