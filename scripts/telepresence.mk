# Telepresence Connect
.PHONY: connect-telepresence
connect-telepresence:
	telepresence --context=kind-$(KIND_CLUSTER) helm install
	telepresence --context=kind-$(KIND_CLUSTER) connect

# Telepresence Disconnect
.PHONY: disconnect-telepresence
disconnect-telepresence:
	@echo "Disconnecting Telepresence..."
	telepresence quit
