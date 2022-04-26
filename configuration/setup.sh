echo "reminder: run configuration/setup.sh <clientID> <clientSecret> where clientID and clientSecret are the credentials from step 2."
echo "setting up remote network agents using clientIt: $1 and secret: $2"
kubectl create namespace demo-agent-prod
kubectl create namespace demo-agent-staging
kubectl create namespace demo-agent-dev
kubectl create namespace demo-agent-prod-eu
kubectl create ns demo-infra
kubectl create ns demo-dev
kubectl create ns demo-staging
kubectl create ns demo-prod
kubectl create ns demo-prod-eu

kubectl -n=demo-agent-prod create secret generic rna-client-credentials --type=string --from-literal=client-secret=$2 --from-literal=client-id=$1
kubectl -n=demo-agent-prod-eu create secret generic rna-client-credentials --type=string --from-literal=client-secret=$2 --from-literal=client-id=$1
kubectl -n=demo-agent-staging create secret generic rna-client-credentials --type=string --from-literal=client-secret=$2 --from-literal=client-id=$1
kubectl -n=demo-agent-dev create secret generic rna-client-credentials --type=string --from-literal=client-secret=$2 --from-literal=client-id=$1


# Optionally Add Armory Chart repo, if you haven't
helm repo add armory https://armory.jfrog.io/artifactory/charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# Update repo to fetch latest armory charts
helm repo update
# Install or Upgrade armory rna chart
helm upgrade --install armory-rna-prod armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set agentIdentifier=demo-prod-west-cluster \
    -n demo-agent-prod
helm upgrade --install armory-rna-prod-eu armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set agentIdentifier=demo-prod-eu-cluster \
    -n demo-agent-prod-eu
helm upgrade --install armory-rna-staging armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set agentIdentifier=demo-staging-cluster \
    -n demo-agent-staging
helm upgrade --install armory-rna-dev armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set agentIdentifier=demo-dev-cluster \
    -n demo-agent-dev

helm install prometheus prometheus-community/kube-prometheus-stack -n=demo-infra --set "kube-state-metrics.metricAnnotationsAllowList[0]=pods=[*]" --set "global.scrape_interval=5s"

BASEDIR=$(dirname $0)

kubectl apply -f "$BASEDIR/../manifests/potato-facts-external-service.yml" -n demo-prod-eu #Temporary workaround for YODL-300. deploying service along side deployment does not work for Blue/Green.
#container_cpu_load_average_10s{namespace="borealis", job="kubelet"} * on (pod)  group_left (label_app) sum(kube_pod_labels{job="kube-state-metrics",label_app="hostname",namespace="borealis"}) by (label_app, pod)

# also tried: --set kube-state-metrics.metricLabelsAllowlist=pods=[*]
# k -n=borealis-demo-infra port-forward service/prometheus-kube-prometheus-prometheus 9090
# example prometheus query for CPU load for pods in a replica set. container_cpu_load_average_10s{name=~"k8s_POD_hostname-5b8bc655f6.+"}
