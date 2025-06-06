GITHUB_ID := prastuvwxyz
GITHUB_REPO := k8s-local-cluster
GITHUB_BRANCH := main
GITHUB_CLUSTER_FOLDER := clusters/local

# Bootstrap Flux CD
.PHONY: bootstrap-flux
bootstrap-flux:
	@echo "Bootstrapping Flux CD with GitHub repository..."
	@flux check --pre
	@flux bootstrap github \
		--token-auth \
		--owner=$(GITHUB_ID) \
		--repository=$(GITHUB_REPO) \
		--branch=$(GITHUB_BRANCH) \
		--path=$(GITHUB_CLUSTER_FOLDER) \
		--personal

# Check Flux status
.PHONY: flux-status
flux-status:
	@echo "Checking Flux status..."
	@flux get all
