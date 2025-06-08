# CNPG Operator management
.PHONY: install-cnpg
install-cnpg: preload-cnpg install-cnpg-crds
	@echo "Installing CloudNativePG Operator..."
	@kubectl kustomize infrastructure/operator/cnpg/local | kubectl apply -f -
	@echo "CloudNativePG Operator installed successfully!"

.PHONY: install-cnpg-crds
install-cnpg-crds:
	@echo "Installing CloudNativePG CRDs directly..."
	@./scripts/install-cnpg-crds.sh

.PHONY: deploy-postgres
deploy-postgres: install-cnpg
	@echo "Checking if CRDs are available before deploying PostgreSQL..."
	@./scripts/check-crds.sh || (echo "Error: CloudNativePG CRDs not available. Try running 'make install-cnpg-crds'" && exit 1)
	@echo "Creating namespace and secrets first..."
	@kubectl apply -f apps/database/base/namespace.yaml
	@kubectl apply -f apps/database/local/superuser-secret.yaml
	@kubectl apply -f apps/database/local/user-secret.yaml
	@echo "Deploying PostgreSQL instance with 1 replica..."
	@kubectl kustomize apps/database/local | kubectl apply -f -
	@echo "PostgreSQL deployment initiated. Checking status..."
	@kubectl wait --namespace database --for=condition=Ready clusters.postgresql.cnpg.io postgres-cluster --timeout=300s || true
	@echo "You can check the status with: kubectl get clusters.postgresql.cnpg.io -n database"
	@echo "To connect to PostgreSQL, run: kubectl -n database exec -it postgres-cluster-1 -- psql -U postgres"

.PHONY: cnpg-status
cnpg-status:
	@echo "CloudNativePG Operator Status:"
	@kubectl get pods -n cnpg-system
	@echo "\nPostgreSQL Cluster Status:"
	@kubectl get clusters.postgresql.cnpg.io -n database
	@kubectl get pods -n database
	@echo "\nGet PostgreSQL Connection Details:"
	@kubectl get secrets -n database postgres-cluster-app -o jsonpath='{.data.uri}' | base64 -d || echo "Connection details not available yet"

.PHONY: pg-disk-usage
pg-disk-usage:
	@echo "Monitoring PostgreSQL disk usage..."
	@./scripts/pvc-monitor.sh database

.PHONY: pg-backups
pg-backups:
	@echo "PostgreSQL Backup Status:"
	@kubectl get backups -n database
	@echo "\nScheduled Backups:"
	@kubectl get scheduledbackups -n database
	
.PHONY: pg-restore
pg-restore:
	@if [ -z "$(BACKUP)" ]; then \
	  echo "Error: BACKUP parameter is required"; \
	  echo "Usage: make pg-restore BACKUP=<backup-name>"; \
	  echo "\nAvailable backups:"; \
	  kubectl get backups -n database; \
	  exit 1; \
	fi
	@echo "Restoring from backup: $(BACKUP)"
	@./scripts/pg-restore.sh $(BACKUP)

.PHONY: pg-connect
pg-connect:
	@./scripts/pg-connect.sh $(USER) $(DB)

.PHONY: pg-connect-app
pg-connect-app:
	@./scripts/pg-connect.sh app_user app
	
.PHONY: pg-port-forward
pg-port-forward:
	@./scripts/pg-port-forward.sh $(PORT) false

.PHONY: pg-port-forward-bg
pg-port-forward-bg:
	@./scripts/pg-port-forward.sh $(PORT) true
	
.PHONY: pg-logs
pg-logs:
	@./scripts/pg-logs.sh $(LINES) true

.PHONY: pg-logs-tail
pg-logs-tail:
	@./scripts/pg-logs.sh $(LINES) false
	
.PHONY: pg-export
pg-export:
	@./scripts/pg-data.sh export $(DB) $(FILE)

.PHONY: pg-import
pg-import:
	@if [ -z "$(FILE)" ]; then \
	  echo "Error: FILE parameter is required"; \
	  echo "Usage: make pg-import DB=dbname FILE=filename.sql"; \
	  exit 1; \
	fi
	@./scripts/pg-data.sh import $(DB) $(FILE)
	
.PHONY: pg-verify
pg-verify:
	@./scripts/verify-pg-setup.sh
