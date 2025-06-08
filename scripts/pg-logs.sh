#!/bin/bash
# Script to view PostgreSQL logs
# Usage: ./pg-logs.sh [lines] [follow]

LINES=${1:-100}
FOLLOW=${2:-true}
NAMESPACE="database"
CLUSTER_NAME="postgres-cluster"

# Function to get the primary pod
get_primary_pod() {
  kubectl get pods -n ${NAMESPACE} -l postgresql=${CLUSTER_NAME},role=primary -o name 2>/dev/null | cut -d'/' -f2
}

# Function to view logs
view_logs() {
  local pod=$1
  local follow=$2
  local lines=$3
  
  if [ "$follow" = "true" ]; then
    echo "Viewing PostgreSQL logs (Press Ctrl+C to exit)..."
    kubectl exec -it -n ${NAMESPACE} ${pod} -- tail -f -n ${lines} /controller/log/postgres/postgresql.log
  else
    echo "Showing last ${lines} lines of PostgreSQL logs..."
    kubectl exec -it -n ${NAMESPACE} ${pod} -- tail -n ${lines} /controller/log/postgres/postgresql.log
  fi
}

# Function to list available log files
list_log_files() {
  local pod=$1
  echo "Available log files:"
  kubectl exec -it -n ${NAMESPACE} ${pod} -- ls -la /controller/log/postgres/
}

# Main function
main() {
  # Get primary pod
  PRIMARY_POD=$(get_primary_pod)
  if [ -z "$PRIMARY_POD" ]; then
    echo "❌ Could not find the primary PostgreSQL pod"
    echo "Available pods in namespace ${NAMESPACE}:"
    kubectl get pods -n ${NAMESPACE}
    exit 1
  fi
  
  # List log files
  list_log_files ${PRIMARY_POD}
  echo ""
  
  # View logs
  view_logs ${PRIMARY_POD} ${FOLLOW} ${LINES}
}

# Run main function
main
