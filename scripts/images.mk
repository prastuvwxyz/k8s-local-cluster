KIND := kindest/node:v1.32.0

FLUXCD-SOURCE-CONTROLLER := ghcr.io/fluxcd/source-controller:v1.6.0
FLUXCD-NOTIFICATION-CONTROLLER := ghcr.io/fluxcd/notification-controller:v1.6.0
FLUXCD-KUSTOMIZE-CONTROLLER := ghcr.io/fluxcd/kustomize-controller:v1.6.0
FLUXCD-HELM-CONTROLLER := ghcr.io/fluxcd/helm-controller:v1.3.0

# CloudNativePG images - using latest versions
CNPG-OPERATOR := ghcr.io/cloudnative-pg/cloudnative-pg:1.26.0
CNPG-POSTGRES := ghcr.io/cloudnative-pg/postgresql:17.5-standard-bookworm

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

.PHONY: preload-cnpg
preload-cnpg:
	@echo "Preloading CloudNativePG images into the Kind cluster..."
	docker pull $(CNPG-OPERATOR)
	docker pull $(CNPG-POSTGRES)
	kind load docker-image $(CNPG-OPERATOR) --name $(KIND_CLUSTER)
	kind load docker-image $(CNPG-POSTGRES) --name $(KIND_CLUSTER)
	@echo "CloudNativePG images preloaded successfully!"
