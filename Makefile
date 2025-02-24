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

# metric
ALTINITY-METRICS-EXPORTER := altinity/metrics-exporter:0.23.3

# postgres
CLOUDNATIVE-PG := ghcr.io/cloudnative-pg/cloudnative-pg:1.25.0
CLOUDNATIVE-PG-POSTGRES := ghcr.io/cloudnative-pg/postgresql:16.7-bookworm
FLYWAY := flyway/flyway:10.1-alpine

# strimzi kafka
STRIMZI-OPERATOR := quay.io/strimzi/operator:0.40.0
STRIMZI-KAFKA := quay.io/strimzi/kafka:0.40.0-kafka-3.7.0
STRIMZI-KAFKA-CONNECT := strimzi-kafka-connect:0.40.0-kafka-3.7.0

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
	@docker pull $(STRIMZI-OPERATOR)
	@docker pull $(STRIMZI-KAFKA)
	@docker build --progress=plain -f ./docker-images/strimzi-kafka-connect.Dockerfile --tag $(STRIMZI-KAFKA-CONNECT) .
	@docker pull $(ALTINITY-METRICS-EXPORTER)
	@docker pull $(CLOUDNATIVE-PG)
	@docker pull $(CLOUDNATIVE-PG-POSTGRES)
	@docker pull $(FLYWAY)
	

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
	@kind load docker-image $(STRIMZI-OPERATOR) --name $(CLUSTER_NAME)
	@kind load docker-image $(STRIMZI-KAFKA) --name $(CLUSTER_NAME)
	@kind load docker-image $(STRIMZI-KAFKA-CONNECT) --name $(CLUSTER_NAME)
	@kind load docker-image $(ALTINITY-METRICS-EXPORTER) --name $(CLUSTER_NAME)
	@kind load docker-image $(CLOUDNATIVE-PG) --name $(CLUSTER_NAME)
	@kind load docker-image $(CLOUDNATIVE-PG-POSTGRES) --name $(CLUSTER_NAME)
	@kind load docker-image $(FLYWAY) --name $(CLUSTER_NAME)

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
	telepresence --context=kind-k8s-local-cluster helm install
	telepresence --context=kind-k8s-local-cluster connect

k8s-stop-telepresence:
	@telepresence quit -s || true
	@echo "Telepresence has been stopped."

k8s-delete-cluster:
	@kind delete cluster --name $(CLUSTER_NAME)
	@echo "Cluster $(CLUSTER_NAME) has been deleted."
