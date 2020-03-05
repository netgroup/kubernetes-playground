#!/bin/sh

configuration_file_path="$1"

echo "Initializing Kubernetes master with configuration file: $configuration_file_path. Contents: $(cat "$configuration_file_path")"
kubeadm init --config "$configuration_file_path"

# Setup root user environment
mkdir -p "$HOME"/.kube
cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config

# Setup vagrant user environment
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube
chown vagrant:vagrant /home/vagrant/.kube/config

network_plugin_id="$2"
echo "Installing $network_plugin_id network plugin"

if [ "$network_plugin_id" = 'weavenet' ]; then
    kubever=$(kubectl version | base64 | tr -d '\n')
    export kubever
    kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
elif [ "$network_plugin_id" = 'calico' ]; then
    kubectl apply -f /tmp/calico-config.yaml
    # /tmp/calico-config.yaml is generated from ansible/playbooks/templates/calico-config.yaml.j2
    # which is based on https://docs.projectcalico.org/v3.10/manifests/calico.yaml
elif [ "$network_plugin_id" = 'flannel' ]; then
    kubectl apply -f /tmp/kube-flannel-config.yaml
    # /tmp/kube-flannel-config.yaml is generated from ansible/playbooks/templates/kube-flannel-config.yaml.j2
    # which is based on https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
fi
