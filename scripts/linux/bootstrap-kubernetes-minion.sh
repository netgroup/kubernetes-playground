#!/bin/sh

master_address="$1"
token="$2"

kubernetes_cluster_ip_cidr="10.96.0.0/12"
echo "Setting up a route to Kubernetes cluster IP ($kubernetes_cluster_ip_cidr) via $master_address"
ip route add "$kubernetes_cluster_ip_cidr" via "$master_address"

echo "Initializing Kubernetes minion to join: $advertise_address and token: $token"
kubeadm join "$master_address":6443 --token "$token" --discovery-token-unsafe-skip-ca-verification
