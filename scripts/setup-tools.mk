.PHONY: brew-common check-tools
brew-common:
	@echo "Installing required tools using Homebrew..."
	brew update
	brew list kind || brew install kind
	brew list kubectl || brew install kubectl
	brew list kustomize || brew install kustomize
	brew list fluxcd/tap/flux || brew install fluxcd/tap/flux
	@echo "All required tools installed successfully!"

# Check if required tools are installed and display their versions
check-tools:
	@echo "Checking required tools..."
	@echo -n "kind: "
	@if command -v kind >/dev/null 2>&1; then \
		echo -n "✅ Installed, version: "; \
		kind --version; \
	else \
		echo "❌ Not installed"; \
	fi
	@echo -n "kubectl: "
	@if command -v kubectl >/dev/null 2>&1; then \
		echo -n "✅ Installed, version: "; \
		kubectl version --client --short; \
	else \
		echo "❌ Not installed"; \
	fi
	@echo -n "kustomize: "
	@if command -v kustomize >/dev/null 2>&1; then \
		echo -n "✅ Installed, version: "; \
		kustomize version --short; \
	else \
		echo "❌ Not installed"; \
	fi
	@echo -n "flux: "
	@if command -v flux >/dev/null 2>&1; then \
		echo -n "✅ Installed, version: "; \
		flux --version; \
	else \
		echo "❌ Not installed"; \
	fi
