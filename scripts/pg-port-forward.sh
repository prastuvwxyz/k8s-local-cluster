#!/bin/bash
# Script to create a port-forward to PostgreSQL
# Usage: ./pg-port-forward.sh [local-port] [background]

LOCAL_PORT=${1:-5432}
RUN_IN_BACKGROUND=${2:-false}
NAMESPACE="database"
SERVICE="postgres-cluster-rw"

# Check if port-forward is already running
check_running() {
  # Get PIDs of existing port-forwards to this port
  PIDs=$(lsof -i :${LOCAL_PORT} | grep kubectl | awk '{print $2}' 2>/dev/null)
  
  if [ ! -z "$PIDs" ]; then
    echo "⚠️ A port-forward is already running on port ${LOCAL_PORT} with PID(s): $PIDs"
    echo "You can kill it with: kill $PIDs"
    return 0
  fi
  
  return 1
}

# Create the port-forward
create_port_forward() {
  echo "🔄 Creating port-forward from localhost:${LOCAL_PORT} to ${SERVICE}.${NAMESPACE}:5432"
  
  if [ "$RUN_IN_BACKGROUND" = "true" ]; then
    kubectl port-forward -n ${NAMESPACE} svc/${SERVICE} ${LOCAL_PORT}:5432 &>/dev/null &
    PID=$!
    echo "✅ Port-forward running in background with PID: $PID"
    echo "You can kill it with: kill $PID"
    echo ""
    echo "Connection details:"
    echo "  Host: localhost"
    echo "  Port: ${LOCAL_PORT}"
    echo "  User: postgres or app_user"
    echo "  Password: Check the secrets in the database namespace"
    echo "  Database: postgres, app_db or app"
  else
    echo "Press Ctrl+C to stop the port-forward"
    kubectl port-forward -n ${NAMESPACE} svc/${SERVICE} ${LOCAL_PORT}:5432
  fi
}

# Main function
main() {
  # Check if the service exists
  if ! kubectl get svc -n ${NAMESPACE} ${SERVICE} &>/dev/null; then
    echo "❌ Service '${SERVICE}' not found in namespace '${NAMESPACE}'"
    echo "Make sure you've deployed PostgreSQL with 'make deploy-postgres'"
    exit 1
  fi
  
  # Check if port-forward is already running
  if check_running; then
    echo "Would you like to proceed anyway? (y/n)"
    read answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
      echo "Port-forward not created."
      exit 0
    fi
  fi
  
  create_port_forward
}

# Run main function
main
