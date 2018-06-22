#!/bin/sh

set -e

kubernetes_namespace="docker-registry"

kubectl create secret generic docker-registry-tls-cert --from-file=/opt/tls/self_signed/tls.crt --from-file=/opt/tls/self_signed/tls.key --namespace "$kubernetes_namespace"

/usr/local/bin/helm install stable/docker-registry --name docker-registry --namespace "$kubernetes_namespace" --values /vagrant/kubernetes/docker-registry/values.yaml
