#!/bin/sh

set -e

helm install stable/prometheus --name prometheus --namespace prometheus --values /vagrant/kubernetes/prometheus/values.yaml
helm install stable/grafana --name grafana --namespace grafana --values /vagrant/kubernetes/grafana/values.yaml
