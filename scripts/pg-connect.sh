#!/bin/bash
# Script to connect to PostgreSQL database
# Usage: ./pg-connect.sh [user] [database]

USER=${1:-postgres}
DATABASE=${2:-postgres}
NAMESPACE="database"
CLUSTER_NAME="postgres-cluster"
POD_PREFIX="${CLUSTER_NAME}"

# Function to check if PostgreSQL cluster is ready
check_postgres() {
  kubectl get clusters.postgresql.cnpg.io -n ${NAMESPACE} ${CLUSTER_NAME} &> /dev/null
  return $?
}

# Function to get the primary pod
get_primary_pod() {
  kubectl get pods -n ${NAMESPACE} -l postgresql=${CLUSTER_NAME},role=primary -o name 2>/dev/null | cut -d'/' -f2
}

# Main function
main() {
  # Check if PostgreSQL cluster exists
  if ! check_postgres; then
    echo "❌ PostgreSQL cluster '${CLUSTER_NAME}' not found in namespace '${NAMESPACE}'"
    echo "Make sure you've deployed PostgreSQL with 'make deploy-postgres'"
    exit 1
  fi
  
  # Get primary pod
  PRIMARY_POD=$(get_primary_pod)
  if [ -z "$PRIMARY_POD" ]; then
    echo "❌ Could not find the primary PostgreSQL pod"
    echo "Available pods in namespace ${NAMESPACE}:"
    kubectl get pods -n ${NAMESPACE}
    exit 1
  fi
  
  echo "🔄 Connecting to PostgreSQL (User: ${USER}, Database: ${DATABASE}, Pod: ${PRIMARY_POD})..."
  echo "Type '\q' to exit"
  echo ""
  
  kubectl -n ${NAMESPACE} exec -it ${PRIMARY_POD} -- psql -U ${USER} -d ${DATABASE}
}

# Run main function
main
