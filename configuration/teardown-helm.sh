# Uninstall the RNAs using Helm
# Delete corresponding namespaces
# You shouldn't have to delete clusterrole and clusterrolebinding objects
# because `helm uninstall` does that
# helm uninstall [RELEASE] [flags]

helm uninstall sample-rna-prod-us  -n sample-rna-prod-us
helm uninstall sample-rna-prod-eu -n sample-rna-prod-eu
helm uninstall sample-rna-staging -n sample-rna-staging
helm uninstall sample-rna-test -n sample-rna-test

# Delete RNA namespaces
kubectl delete namespace sample-rna-prod-us
kubectl delete namespace sample-rna-prod-eu
kubectl delete namespace sample-rna-staging
kubectl delete namespace sample-rna-test

# Delete app namespaces
kubectl delete ns sample-test
kubectl delete ns sample-staging
kubectl delete ns sample-prod-us
kubectl delete ns sample-prod-eu
