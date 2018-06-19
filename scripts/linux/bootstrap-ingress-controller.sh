#!/bin/sh

set -e

openssl req -newkey rsa:4096 -nodes -keyout tls.key -x509 -days 365 -out tls.crt -subj "/C=IT/ST=Lazio/L=Rome /O=Dedalus/OU=Hero/CN=*.kubernetes-playground.local/emailAddress=marco.ferrari@dedalus.eu"
kubectl create secret generic traefik-cert --from-file=tls.crt --from-file=tls.key --namespace kube-system

kubectl apply -f /vagrant/kubernetes/traefik
