# Makefile for managing a local Kubernetes cluster using Kind
include scripts/*

# Variables
KIND_CLUSTER := local
KIND_CONFIG := kind-config.yaml

# Default target
.PHONY: help
help:
	@echo "Available targets:"
	@echo ""
	@echo "Environment Management:"
	@echo "  up                       - Set up the complete environment (create cluster, preload images, bootstrap Flux, connect Telepresence)"
	@echo "  down                     - Tear down the complete environment (disconnect Telepresence, delete cluster)"
	@echo ""
	@echo "Tools Management:"
	@echo "  brew-common              - Install required tools (kind, kubectl, kustomize, flux) using Homebrew"
	@echo "  check-tools              - Check if required tools are installed and display their versions"
	@echo ""
	@echo "Cluster Management:"
	@echo "  create-cluster           - Create a new Kind cluster"
	@echo "  delete-cluster           - Delete the Kind cluster"
	@echo "  get-clusters             - List all Kind clusters"
	@echo "  cluster-info             - Show information about the cluster"
	@echo "  get-nodes                - List all nodes in the cluster"
	@echo "  get-pods                 - List all pods in the cluster"
	@echo "  install-dashboard        - Install Kubernetes dashboard"
	@echo ""
	@echo "Flux CD Management:"
	@echo "  bootstrap-flux           - Bootstrap Flux CD with GitHub repository"
	@echo "  flux-status              - Check Flux status"
	@echo ""
	@echo "Telepresence Management:"
	@echo "  connect-telepresence     - Connect to the cluster using Telepresence"
	@echo "  disconnect-telepresence  - Disconnect from the cluster"
	@echo ""
	@echo "Image Management:"
	@echo "  preload-fluxcd           - Preload FluxCD images into the Kind cluster"
	@echo "  preload-telepresence     - Preload Telepresence images into the Kind cluster"

# Create a new Kind cluster
.PHONY: create-cluster
create-cluster:
	@echo "Checking if Kind cluster '$(KIND_CLUSTER)' exists..."
	@if kind get clusters | grep -q "^$(KIND_CLUSTER)$$"; then \
		echo "Cluster '$(KIND_CLUSTER)' already exists, skipping creation."; \
		kubectl cluster-info --context kind-$(KIND_CLUSTER); \
		kubectl get nodes; \
	else \
		echo "Creating Kind cluster '$(KIND_CLUSTER)'..."; \
		kind create cluster --name $(KIND_CLUSTER) --config $(KIND_CONFIG); \
		kubectl wait --timeout=120s --namespace=local-path-storage --for=condition=Available deployment/local-path-provisioner; \
		echo "Cluster created successfully!"; \
		kubectl cluster-info --context kind-$(KIND_CLUSTER); \
		kubectl get nodes; \
	fi

# Delete the Kind cluster
.PHONY: delete-cluster
delete-cluster:
	@echo "Deleting Kind cluster '$(KIND_CLUSTER)'..."
	kind delete cluster --name $(KIND_CLUSTER)
	@echo "Cluster deleted successfully!"

# List all Kind clusters
.PHONY: get-clusters
get-clusters:
	@echo "Listing all Kind clusters..."
	kind get clusters

# Show information about the cluster
.PHONY: cluster-info
cluster-info:
	@echo "Cluster information:"
	kubectl cluster-info --context kind-$(KIND_CLUSTER)

# List all nodes in the cluster
.PHONY: get-nodes
get-nodes:
	@echo "Listing all nodes in the cluster:"
	kubectl get nodes

# List all pods in the cluster
.PHONY: get-pods
get-pods:
	@echo "Listing all pods in the cluster:"
	kubectl get pods -A

# Install Kubernetes dashboard
.PHONY: install-dashboard
install-dashboard:
	@echo "Installing Kubernetes dashboard..."
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
	@echo "Dashboard installed. To access it, run:"
	@echo "kubectl proxy"
	@echo "Then visit: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
	@echo "To create a token for login, run:"
	@echo "kubectl -n kubernetes-dashboard create token kubernetes-dashboard"

# Set up the complete environment
.PHONY: up
up:
	@echo "Setting up the complete environment..."
	@echo "Step 1/5: Creating Kind cluster..."
	@make create-cluster
	@echo "Step 2/5: Preloading FluxCD images..."
	@make preload-fluxcd
	@echo "Step 3/5: Preloading Telepresence images..."
	@make preload-telepresence
	@echo "Step 4/5: Bootstrapping Flux CD..."
	@make bootstrap-flux
	@echo "Step 5/5: Connecting Telepresence..."
	@make connect-telepresence
	@echo "Environment setup completed successfully!"

# Tear down the complete environment
.PHONY: down
down:
	@echo "Tearing down the complete environment..."
	@make disconnect-telepresence
	@make delete-cluster
	@echo "Environment torn down successfully!"
