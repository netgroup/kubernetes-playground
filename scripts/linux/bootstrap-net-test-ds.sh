#!/bin/sh
echo "Apply Net-Test DaemonSet"
kubectl apply -f /vagrant/kubernetes/kites/net-test_ds.yaml

echo "Check until the pods are in the Running state on each node, when finished press CTRL+C":
watch kubectl get pod -o wide
