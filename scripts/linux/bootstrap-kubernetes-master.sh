#!/bin/sh

configuration_file_path="$1"

echo "Initializing Kubernetes master with configuration file: $configuration_file_path. Contents: $(cat "$configuration_file_path")"
kubeadm init --config "$configuration_file_path"

# Setup root user environment
mkdir -p "$HOME"/.kube
cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
chown $(id -u):$(id -g) "$HOME"/.kube/config

# Setup vagrant user environment
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

network_plugin_id="$2"
echo "Installing $network_plugin_id network plugin"

if [[ "$network_plugin_id" == 'weavenet' ]]; then
    export kubever=$(kubectl version | base64 | tr -d '\n')
    kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
elif [[ "$network_plugin_id" == 'calico' ]]; then
    kubectl apply -f https://docs.projectcalico.org/v3.10/manifests/calico.yaml
fi
