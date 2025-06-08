#!/bin/bash
# Script to monitor PostgreSQL Persistent Volume Claims
# Usage: ./pvc-monitor.sh [namespace]

NAMESPACE=${1:-database}

echo "Monitoring PostgreSQL PVCs in namespace: $NAMESPACE"
echo "----------------------------------------------"

# Get all PVCs
kubectl get pvc -n $NAMESPACE -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,CAPACITY:.spec.resources.requests.storage,VOLUME:.spec.volumeName

echo ""
echo "Storage Usage:"
echo "-------------"

# Get all pods
PODS=$(kubectl get pods -n $NAMESPACE -l postgresql -o jsonpath='{.items[*].metadata.name}')

for POD in $PODS; do
  echo "Pod: $POD"
  # Get storage usage from PostgreSQL
  kubectl exec -it $POD -n $NAMESPACE -- bash -c "df -h /var/lib/postgresql/data" 2>/dev/null || echo "Cannot access storage info for $POD"
  echo ""
  
  # Get pg_database_size info
  echo "Database Sizes:"
  kubectl exec -it $POD -n $NAMESPACE -- psql -U postgres -c "SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) AS size FROM pg_database ORDER BY pg_database_size(pg_database.datname) DESC;" 2>/dev/null || echo "Cannot access database size info for $POD"
  echo ""
done

echo "Top Tables by Size:"
kubectl exec -it postgres-cluster-1 -n $NAMESPACE -- psql -U postgres -c "SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size FROM pg_tables WHERE schemaname NOT IN ('pg_catalog', 'information_schema') ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC LIMIT 10;" 2>/dev/null || echo "Cannot access table size info"
