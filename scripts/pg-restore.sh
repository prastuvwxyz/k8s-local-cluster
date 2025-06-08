#!/bin/bash
# Script to restore PostgreSQL from a backup
# Usage: ./pg-restore.sh [backup-name]

set -e

BACKUP_NAME=${1}

if [ -z "$BACKUP_NAME" ]; then
  echo "Error: Backup name is required"
  echo "Usage: ./pg-restore.sh [backup-name]"
  echo ""
  echo "Available backups:"
  kubectl get backups -n database
  exit 1
fi

# Check if the backup exists
if ! kubectl get backup -n database "$BACKUP_NAME" &> /dev/null; then
  echo "Error: Backup '$BACKUP_NAME' not found in namespace 'database'"
  echo "Available backups:"
  kubectl get backups -n database
  exit 1
fi

# Generate a unique name for the restored cluster
TIMESTAMP=$(date +%Y%m%d%H%M%S)
RESTORED_CLUSTER_NAME="postgres-restored-${TIMESTAMP}"

echo "Creating PostgreSQL restore manifest..."
cat <<EOF > pg-restore.yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: ${RESTORED_CLUSTER_NAME}
  namespace: database
spec:
  instances: 1
  bootstrap:
    recovery:
      backup:
        name: ${BACKUP_NAME}
  superuserSecret:
    name: postgres-super-secret
  storage:
    size: 30Gi
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1
      memory: 2Gi
EOF

echo "Applying the restore manifest..."
kubectl apply -f pg-restore.yaml

echo "Waiting for the restored cluster to be ready..."
kubectl wait --namespace database --for=condition=Ready clusters.postgresql.cnpg.io ${RESTORED_CLUSTER_NAME} --timeout=600s || true

echo "Restored cluster: ${RESTORED_CLUSTER_NAME}"
echo "To connect to the restored PostgreSQL cluster, run:"
echo "kubectl -n database exec -it ${RESTORED_CLUSTER_NAME}-1 -- psql -U postgres"

# Cleanup
rm pg-restore.yaml
