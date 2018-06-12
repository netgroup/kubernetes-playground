#!/bin/sh

set -e

/usr/local/bin/helm install stable/docker-registry --name docker-registry --namespace docker-registry --values /vagrant/kubernetes/docker-registry/values.yaml
