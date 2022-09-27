# delete k8s clusterrole and clusterrolebinding in default namespace
# kubectl delete clusterrole rna-armory-rna-cr
# kubeclt delete clusterrolebinding rna-armory-rna-cr-binding


# helm uninstall removes all of the resources associated with the last release of the chart as well as the release history, freeing it up for future use.

helm uninstall rbac-dev-agent  -n rbac-dev-agent
helm uninstall rbac-test-agent  -n rbac-test-agent
helm uninstall rbac-staging-agent  -n rbac-staging-agent
helm uninstall rbac-prod-agent  -n rbac-prod-agent

# delete namespaces

kubectl delete namespace rbac-dev-agent
kubectl delete namespace rbac-test-agent
kubectl delete namespace rbac-staging-agent
kubectl delete namespace rbac-prod-agent
