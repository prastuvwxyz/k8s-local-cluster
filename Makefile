# base
KIND_IMAGE := kindest/node:v1.32.0
TELEPRESENCE_IMAGE := datawire/tel2:2.19.0
TELEPRESENCE_MANAGER := docker.io/datawire/ambassador-telepresence-manager:2.20.0
TELEPRESENCE_AGENT := docker.io/datawire/ambassador-telepresence-agent:1.14.5
CLUSTER_NAME := k8s-local-cluster

# flux
FLUXCD_SOURCE := ghcr.io/fluxcd/source-controller:v1.4.1
FLUXCD_NOTIFICATION := ghcr.io/fluxcd/notification-controller:v1.4.0
FLUXCD_KUSTOMIZE := ghcr.io/fluxcd/kustomize-controller:v1.4.0
FLUXCD_HELM := fluxcd/helm-controller:v1.1.0

# github
GITHUB_OWNER := prastuvwxyz
GITHUB_REPO := k8s-local-cluster
GITHUB_BRANCH := main

setup-tools: install-common-tools pull-docker-images
k8s-up: validate k8s-create-cluster k8s-load-docker-image k8s-fluxcd-bootstrap k8s-init-telepresence
k8s-down: k8s-stop-telepresence k8s-delete-cluster

validate:
	@which kind || (echo "Kind is not installed. Please install Kind CLI." && exit 1)
	@which flux || (echo "Flux CLI is not installed. Please install Flux CLI." && exit 1)
	@which telepresence || (echo "Telepresence CLI is not installed. Please install Telepresence." && exit 1)
	@echo "All required tools are installed."

install-common-tools:
	@brew update
	@brew list kubectl || brew install kubectl
	@brew list kustomize || brew install kustomize
	@brew list k9s || brew install k9s
	@brew list fluxcd/tap/flux || brew install fluxcd/tap/flux

pull-docker-images:
	@echo "Pulling required Docker images..."
	@docker pull $(KIND_IMAGE)
	@docker pull $(TELEPRESENCE_IMAGE)
	@docker pull $(TELEPRESENCE_MANAGER)
	@docker pull $(TELEPRESENCE_AGENT)
	@docker pull $(FLUXCD_SOURCE)
	@docker pull $(FLUXCD_NOTIFICATION)
	@docker pull $(FLUXCD_KUSTOMIZE)
	@docker pull $(FLUXCD_HELM)

k8s-wait-local-path:
	@kubectl wait --timeout=120s --namespace=local-path-storage --for=condition=Available deployment/local-path-provisioner

k8s-create-cluster:
	@echo "Creating Kind cluster with name $(CLUSTER_NAME) and image $(KIND_IMAGE)..."
	@kind create cluster --image $(KIND_IMAGE) --name $(CLUSTER_NAME)
	@make k8s-wait-local-path

k8s-load-docker-image:
	@echo "Loading Docker images into Kind cluster..."
	@kind load docker-image $(FLUXCD_SOURCE) --name $(CLUSTER_NAME)
	@kind load docker-image $(FLUXCD_NOTIFICATION) --name $(CLUSTER_NAME)
	@kind load docker-image $(FLUXCD_KUSTOMIZE) --name $(CLUSTER_NAME)
	@kind load docker-image $(FLUXCD_HELM) --name $(CLUSTER_NAME)
	@kind load docker-image $(TELEPRESENCE_IMAGE) --name $(CLUSTER_NAME)
	@kind load docker-image $(TELEPRESENCE_MANAGER) --name $(CLUSTER_NAME)
	@kind load docker-image $(TELEPRESENCE_AGENT) --name $(CLUSTER_NAME)

k8s-fluxcd-bootstrap:
	@echo "Bootstrapping FluxCD..."
	@flux check --pre
	@kubectl create namespace flux-system || true
	@flux bootstrap github \
		--owner=$(GITHUB_OWNER) \
		--repository=$(GITHUB_REPO) \
		--branch=$(GITHUB_BRANCH) \
		--path=./clusters/$(CLUSTER_NAME) \
		--personal

k8s-init-telepresence:
	@telepresence --context=kind-$(CLUSTER_NAME) helm install
	@telepresence --context=kind-$(CLUSTER_NAME) connect

k8s-stop-telepresence:
	@telepresence quit -s || true
	@echo "Telepresence has been stopped."

k8s-delete-cluster:
	@kind delete cluster --name $(CLUSTER_NAME)
	@echo "Cluster $(CLUSTER_NAME) has been deleted."
