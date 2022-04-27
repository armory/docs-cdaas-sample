#!/bin/bash
helm uninstall demo-rna-prod-us  -n demo-agent-prod-us
helm uninstall demo-rna-prod-eu -n demo-agent-prod-eu
helm uninstall demo-rna-staging -n demo-agent-staging
helm uninstall demo-rna-dev -n demo-agent-dev
helm uninstall prometheus -n=demo-infra

kubectl  delete namespace demo-agent-prod-us
kubectl  delete namespace demo-agent-prod-eu
kubectl  delete namespace demo-agent-staging
kubectl  delete namespace demo-agent-dev

kubectl  delete namespace demo-infra
kubectl  delete namespace demo-dev
kubectl  delete namespace demo-staging
kubectl  delete namespace demo-prod-us
kubectl  delete namespace demo-prod-eu



