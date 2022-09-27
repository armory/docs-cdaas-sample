#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Format is setup.sh <clientID> <clientSecret> where clientID and clientSecret are the CD-as-a-Service credentials for the example app."
    exit 1
fi

# Create namespaces for Remote Network Agents
kubectl create namespace rbac-dev-agent
kubectl create namespace rbac-test-agent
kubectl create namespace rbac-staging-agent
kubectl create namespace rbac-prod-agent


# Create secrets in each namespace for Client Credentials used by RNAs
kubectl -n=rbac-dev-agent create secret generic rna-client-creds --type=string --from-literal=client-secret=$2 --from-literal=client-id=$1
kubectl -n=rbac-test-agent create secret generic rna-client-creds --type=string --from-literal=client-secret=$2 --from-literal=client-id=$1
kubectl -n=rbac-staging-agent create secret generic rna-client-creds --type=string --from-literal=client-secret=$2 --from-literal=client-id=$1
kubectl -n=rbac-prod-agent create secret generic rna-client-creds --type=string --from-literal=client-secret=$2 --from-literal=client-id=$1


# Optionally Add Armory Chart repo, if you haven't
helm repo add armory https://armory.jfrog.io/artifactory/charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# Update repo to fetch latest armory charts
helm repo update
# Install or Upgrade armory rna chart
helm upgrade --install rbac-dev-agent armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-creds!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-creds!k:client-secret' \
    --set agentIdentifier=rbac-dev-agent \
    -n rbac-dev-agent
helm upgrade --install rbac-test-agent armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-creds!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-creds!k:client-secret' \
    --set agentIdentifier=rbac-test-agent \
    -n rbac-test-agent
helm upgrade --install rbac-staging-agent armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-creds!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-creds!k:client-secret' \
    --set agentIdentifier=rbac-staging-agent \
    -n rbac-staging-agent
helm upgrade --install rbac-prod-agent armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-creds!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-creds!k:client-secret' \
    --set agentIdentifier=rbac-prod-agent \
    -n rbac-prod-agent




