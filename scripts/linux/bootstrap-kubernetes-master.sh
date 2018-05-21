#!/bin/sh

advertise_address="$1"
token="$2"

echo "Initializing Kubernetes master with address: $advertise_address and token: $token"
kubeadm init --apiserver-advertise-address="$advertise_address" --token="$token"

# Setup root user environment
mkdir -p "$HOME"/.kube
cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
chown $(id -u):$(id -g) "$HOME"/.kube/config

# Setup vagrant user environment
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

export kubever=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
