#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Format is setup.sh <clientID> <clientSecret> where clientID and clientSecret are the Borelais credentials for the demo app."
    exit 1
fi

kubectl create namespace demo-agent-prod-us
kubectl create namespace demo-agent-prod-eu
kubectl create namespace demo-agent-staging
kubectl create namespace demo-agent-dev

kubectl create ns demo-infra
kubectl create ns demo-dev
kubectl create ns demo-staging
kubectl create ns demo-prod-us
kubectl create ns demo-prod-eu

kubectl -n=demo-agent-prod-us create secret generic rna-client-credentials --type=string --from-literal=client-secret=$2 --from-literal=client-id=$1
kubectl -n=demo-agent-prod-eu create secret generic rna-client-credentials --type=string --from-literal=client-secret=$2 --from-literal=client-id=$1
kubectl -n=demo-agent-staging create secret generic rna-client-credentials --type=string --from-literal=client-secret=$2 --from-literal=client-id=$1
kubectl -n=demo-agent-dev create secret generic rna-client-credentials --type=string --from-literal=client-secret=$2 --from-literal=client-id=$1


# Optionally Add Armory Chart repo, if you haven't
helm repo add armory https://armory.jfrog.io/artifactory/charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# Update repo to fetch latest armory charts
helm repo update
# Install or Upgrade armory rna chart
helm upgrade --install demo-rna-prod-us armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set agentIdentifier=demo-rna-prod-us-cluster \
    -n demo-agent-prod-us
helm upgrade --install demo-rna-prod-eu armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set agentIdentifier=demo-rna-prod-eu-cluster \
    -n demo-agent-prod-eu
helm upgrade --install demo-rna-staging armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set agentIdentifier=demo-rna-staging-cluster \
    -n demo-agent-staging
helm upgrade --install demo-rna-dev armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set agentIdentifier=demo-rna-dev-cluster \
    -n demo-agent-dev

helm install prometheus prometheus-community/kube-prometheus-stack -n=demo-infra --set "kube-state-metrics.metricAnnotationsAllowList[0]=pods=[*]" --set "global.scrape_interval=5s"

BASEDIR=$(dirname $0)

kubectl apply -f "$BASEDIR/../manifests/potato-facts-external-service.yml" -n demo-prod-eu
