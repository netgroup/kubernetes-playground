#!/bin/sh

set -e

/usr/local/bin/helm install stable/prometheus --name prometheus --namespace prometheus --values /vagrant/kubernetes/prometheus/values.yaml
/usr/local/bin/helm install stable/grafana --name grafana --namespace grafana --values /vagrant/kubernetes/grafana/values.yaml
