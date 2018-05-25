#!/bin/sh

set -e

gluster_kubernetes_archive_name="gluster-kubernetes-master.zip"
gluster_kubernetes_archive_path="/tmp/$gluster_kubernetes_archive_name"
wget https://github.com/gluster/gluster-kubernetes/archive/master.zip
mv master.zip "$gluster_kubernetes_archive_path"

gluster_kubernetes_destination_path="/opt/gluster-kubernetes"
mkdir -p "$gluster_kubernetes_destination_path"
unzip "$gluster_kubernetes_archive_path" -d "$gluster_kubernetes_destination_path"
rm "$gluster_kubernetes_archive_path"
"$gluster_kubernetes_destination_path"/gluster-kubernetes-master/deploy/gk-deploy -gvy /vagrant/kubernetes/glusterfs/topology.json

kubectl apply -f /vagrant/kubernetes/glusterfs/storage-class.yaml
