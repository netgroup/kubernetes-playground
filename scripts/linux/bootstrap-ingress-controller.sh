#!/bin/sh

set -e

kubectl create secret generic traefik-ui-tls-cert --from-file=/opt/tls/self_signed/tls.crt --from-file=/opt/tls/self_signed/tls.key --namespace kube-system

kubectl apply -f /vagrant/kubernetes/traefik
