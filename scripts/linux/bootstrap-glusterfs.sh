#!/bin/sh

set -e

gluster_kubernetes_destination_path="/opt"
"$gluster_kubernetes_destination_path"/gluster-kubernetes-master/deploy/gk-deploy -gvy /vagrant/kubernetes/glusterfs/topology.json


# Workaround for https://github.com/kubernetes/kubernetes/issues/42306
heketi_service_ip="$(kubectl get svc heketi -o=jsonpath='{.spec.clusterIP}')"
sed "s/heketi.default.svc.cluster.local/$heketi_service_ip/g" /vagrant/kubernetes/glusterfs/storage-class.yaml > /vagrant/kubernetes/glusterfs/storage-class.yaml.local

kubectl apply -f /vagrant/kubernetes/glusterfs/storage-class.yaml.local
