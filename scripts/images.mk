KIND := kindest/node:v1.32.0

TELEPRESENCE := docker.io/datawire/tel2:2.19.1
TELEPRESENCE-MANAGER			 := docker.io/datawire/ambassador-telepresence-manager:2.20.2
TELEPRESENCE-AGENT			     := docker.io/ambassador/ambassador-agent:1.0.22

FLUXCD-SOURCE-CONTROLLER := ghcr.io/fluxcd/source-controller:v1.6.0
FLUXCD-NOTIFICATION-CONTROLLER := ghcr.io/fluxcd/notification-controller:v1.6.0
FLUXCD-KUSTOMIZE-CONTROLLER := ghcr.io/fluxcd/kustomize-controller:v1.6.0
FLUXCD-HELM-CONTROLLER := ghcr.io/fluxcd/helm-controller:v1.3.0

.PHONY: preload-fluxcd
preload-fluxcd:
	@echo "Preloading FluxCD images into the Kind cluster..."
	docker pull $(FLUXCD-SOURCE-CONTROLLER)
	docker pull $(FLUXCD-NOTIFICATION-CONTROLLER)
	docker pull $(FLUXCD-KUSTOMIZE-CONTROLLER)
	docker pull $(FLUXCD-HELM-CONTROLLER)
	kind load docker-image $(FLUXCD-SOURCE-CONTROLLER) --name $(KIND_CLUSTER)
	kind load docker-image $(FLUXCD-NOTIFICATION-CONTROLLER) --name $(KIND_CLUSTER)
	kind load docker-image $(FLUXCD-KUSTOMIZE-CONTROLLER) --name $(KIND_CLUSTER)
	kind load docker-image $(FLUXCD-HELM-CONTROLLER) --name $(KIND_CLUSTER)
	@echo "FluxCD images preloaded successfully!"

.PHONY: preload-telepresence
preload-telepresence:
	@echo "Preloading Telepresence images into the Kind cluster..."
	docker pull $(TELEPRESENCE)
	docker pull $(TELEPRESENCE-MANAGER)
	docker pull $(TELEPRESENCE-AGENT)
	kind load docker-image $(TELEPRESENCE) --name $(KIND_CLUSTER)
	kind load docker-image $(TELEPRESENCE-MANAGER) --name $(KIND_CLUSTER)
	kind load docker-image $(TELEPRESENCE-AGENT) --name $(KIND_CLUSTER)
	@echo "Telepresence images preloaded successfully!"
