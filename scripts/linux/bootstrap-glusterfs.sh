#!/bin/sh

set -e

gluster_kubernetes_destination_path="/opt"
"$gluster_kubernetes_destination_path"/gluster-kubernetes-master/deploy/gk-deploy -gvy /vagrant/kubernetes/glusterfs/topology.json

kubectl apply -f /vagrant/kubernetes/glusterfs/storage-class.yaml
