#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Format is setup.sh <clientID> <clientSecret> where clientID and clientSecret are the CD-as-a-Service credentials for the sample app."
    exit 1
fi

# Create namespaces for the Remote Network Agents
kubectl create namespace sample-rna-prod-us
kubectl create namespace sample-rna-prod-eu
kubectl create namespace sample-rna-staging
kubectl create namespace sample-rna-test

# Create secrets in each Remote Network Agent namespace to the RNA can communicate with CD-as-a-Service
kubectl -n=sample-rna-prod-us create secret generic rna-client-credentials --type=string --from-literal=client-secret=$2 --from-literal=client-id=$1
kubectl -n=sample-rna-prod-eu create secret generic rna-client-credentials --type=string --from-literal=client-secret=$2 --from-literal=client-id=$1
kubectl -n=sample-rna-staging create secret generic rna-client-credentials --type=string --from-literal=client-secret=$2 --from-literal=client-id=$1
kubectl -n=sample-rna-test create secret generic rna-client-credentials --type=string --from-literal=client-secret=$2 --from-literal=client-id=$1


# Optionally Add Armory Chart repo, if you haven't
helm repo add armory https://armory.jfrog.io/artifactory/charts
# Update repo to fetch latest armory charts
helm repo update
# Install or Upgrade armory rna chart
# helm upgrade [RELEASE] [CHART] [flags]
# clusterrole and clusterrolebinding are created for each RNA in the `default` namespace
# Because we are using multiple namespaces in a single cluster instead of the same namespace in multiple clusters, use a different release name
# for each namespace. If you were installing one RNA per cluster, you would use the same namespace and release name.
helm upgrade --install sample-rna-prod-us armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set agentIdentifier=sample-rna-prod-us-cluster \
    -n sample-rna-prod-us
helm upgrade --install sample-rna-prod-eu armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set agentIdentifier=sample-rna-prod-eu-cluster \
    -n sample-rna-prod-eu
helm upgrade --install sample-rna-staging armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set agentIdentifier=sample-rna-staging-cluster \
    -n sample-rna-staging
helm upgrade --install sample-rna-test armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set agentIdentifier=sample-rna-test-cluster \
    -n sample-rna-test

# Create namespaces to mimic target deployment clusters
kubectl create ns sample-test
kubectl create ns sample-staging
kubectl create ns sample-prod-us
kubectl create ns sample-prod-eu