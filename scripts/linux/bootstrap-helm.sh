#!/bin/sh

set -e

kubectl create -f /vagrant/kubernetes/tiller/rbac.yaml
/usr/local/bin/helm init --service-account tiller

WAIT=60
s=0
tiller_service=""
echo "Determining tiller service URL ... "
while [[ "x${tiller_service}" == "x" ]] || [[ "${tiller_service}" == "<none>" ]]; do
  if [[ ${s} -ge ${WAIT} ]]; then
    echo "Timed out waiting for tiller service."
    break
  fi
  sleep 10
  ((s+=1))
  tiller_service=$(kubectl describe svc tiller-deploy --namespace kube-system | grep "Endpoints:" | awk '{print $2}')
  echo "Tiller service URL: $tiller_service"
done
