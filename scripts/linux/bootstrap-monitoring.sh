#!/bin/sh

set -e

/usr/local/bin/helm install stable/prometheus --name prometheus --namespace prometheus --values /vagrant/helm/prometheus/values.yaml
/usr/local/bin/helm install stable/grafana --name grafana --namespace grafana --values /vagrant/helm/grafana/values.yaml
