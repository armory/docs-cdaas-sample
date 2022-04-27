helm uninstall demo-rna-prod-us  -n demo-agent-prod-us
helm uninstall demo-rna-prod-eu -n demo-agent-prod-eu
helm uninstall demo-rna-staging -n demo-agent-staging
helm uninstall demo-rna-dev -n demo-agent-dev
helm uninstall prometheus -n=demo-infra
