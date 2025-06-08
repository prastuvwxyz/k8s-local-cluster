#!/bin/bash
# Script to verify CloudNativePG and PostgreSQL setup
# Usage: ./verify-pg-setup.sh

set -e

NAMESPACE="database"
CLUSTER_NAME="postgres-cluster"
OPERATOR_NAMESPACE="cnpg-system"

# Text formatting
BOLD="\033[1m"
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
RESET="\033[0m"

# Helper functions
success() {
  echo -e "${GREEN}✓${RESET} $1"
}

warning() {
  echo -e "${YELLOW}!${RESET} $1"
}

error() {
  echo -e "${RED}✗${RESET} $1"
}

header() {
  echo -e "\n${BOLD}$1${RESET}"
}

# Check if a resource exists
resource_exists() {
  kubectl get $1 -n $2 $3 &> /dev/null
  return $?
}

# Check if CloudNativePG CRDs are installed
check_cnpg_crds() {
  header "Checking CloudNativePG CRDs"
  
  crd_count=0
  for crd in "clusters.postgresql.cnpg.io" "backups.postgresql.cnpg.io" "scheduledbackups.postgresql.cnpg.io" "poolers.postgresql.cnpg.io"; do
    if kubectl get crd $crd &> /dev/null; then
      success "CRD $crd is installed"
      crd_count=$((crd_count + 1))
    else
      error "CRD $crd is not installed"
    fi
  done
  
  if [ "$crd_count" -eq 4 ]; then
    success "All CloudNativePG CRDs are installed"
    return 0
  else
    error "Some CloudNativePG CRDs are missing"
    echo "  Run 'make install-cnpg-crds' to install them"
    return 1
  fi
}

# Check if the CloudNativePG operator is running
check_operator() {
  header "Checking CloudNativePG Operator"
  
  if ! resource_exists "namespace" "" "$OPERATOR_NAMESPACE"; then
    error "Namespace '$OPERATOR_NAMESPACE' doesn't exist"
    return 1
  fi
  
  success "Namespace '$OPERATOR_NAMESPACE' exists"
  
  operator_pods=$(kubectl get pods -n $OPERATOR_NAMESPACE -l app.kubernetes.io/name=cloudnative-pg -o name 2>/dev/null)
  
  if [ -z "$operator_pods" ]; then
    error "CloudNativePG operator pods not found"
    return 1
  fi
  
  operator_ready=0
  for pod in $operator_pods; do
    pod_name=$(echo $pod | cut -d'/' -f2)
    pod_status=$(kubectl get pod -n $OPERATOR_NAMESPACE $pod_name -o jsonpath='{.status.phase}')
    
    if [ "$pod_status" = "Running" ]; then
      ready_status=$(kubectl get pod -n $OPERATOR_NAMESPACE $pod_name -o jsonpath='{.status.containerStatuses[0].ready}')
      if [ "$ready_status" = "true" ]; then
        success "Operator pod $pod_name is running and ready"
        operator_ready=1
      else
        warning "Operator pod $pod_name is running but not ready"
      fi
    else
      error "Operator pod $pod_name is in $pod_status state"
    fi
  done
  
  if [ "$operator_ready" -eq 1 ]; then
    success "CloudNativePG operator is operational"
    return 0
  else
    error "CloudNativePG operator is not fully operational"
    return 1
  fi
}

# Check PostgreSQL cluster
check_pg_cluster() {
  header "Checking PostgreSQL Cluster"
  
  if ! resource_exists "namespace" "" "$NAMESPACE"; then
    error "Namespace '$NAMESPACE' doesn't exist"
    return 1
  fi
  
  success "Namespace '$NAMESPACE' exists"
  
  if ! resource_exists "clusters.postgresql.cnpg.io" "$NAMESPACE" "$CLUSTER_NAME"; then
    error "PostgreSQL cluster '$CLUSTER_NAME' not found"
    return 1
  fi
  
  success "PostgreSQL cluster '$CLUSTER_NAME' exists"
  
  cluster_phase=$(kubectl get clusters.postgresql.cnpg.io -n $NAMESPACE $CLUSTER_NAME -o jsonpath='{.status.phase}' 2>/dev/null)
  if [ "$cluster_phase" = "Cluster in healthy state" ]; then
    success "PostgreSQL cluster is healthy"
  else
    warning "PostgreSQL cluster phase: $cluster_phase"
  fi
  
  # Check pods
  pg_pods=$(kubectl get pods -n $NAMESPACE -l postgresql=$CLUSTER_NAME -o name 2>/dev/null)
  
  if [ -z "$pg_pods" ]; then
    error "No PostgreSQL pods found"
    return 1
  fi
  
  for pod in $pg_pods; do
    pod_name=$(echo $pod | cut -d'/' -f2)
    pod_status=$(kubectl get pod -n $NAMESPACE $pod_name -o jsonpath='{.status.phase}')
    
    if [ "$pod_status" = "Running" ]; then
      ready_status=$(kubectl get pod -n $NAMESPACE $pod_name -o jsonpath='{.status.containerStatuses[0].ready}')
      if [ "$ready_status" = "true" ]; then
        role=$(kubectl get pod -n $NAMESPACE $pod_name -o jsonpath='{.metadata.labels.role}')
        success "Pod $pod_name is running and ready (role: $role)"
      else
        warning "Pod $pod_name is running but not ready"
      fi
    else
      error "Pod $pod_name is in $pod_status state"
    fi
  done
  
  # Check services
  header "Checking PostgreSQL Services"
  
  for svc in "-rw" "-r" ""; do
    service_name="${CLUSTER_NAME}${svc}"
    if resource_exists "service" "$NAMESPACE" "$service_name"; then
      success "Service $service_name exists"
    else
      error "Service $service_name doesn't exist"
    fi
  done
  
  # Check secrets
  header "Checking PostgreSQL Secrets"
  
  for secret in "postgres-super-secret" "postgres-user-secret" "$CLUSTER_NAME-app"; do
    if resource_exists "secret" "$NAMESPACE" "$secret"; then
      success "Secret $secret exists"
    else
      error "Secret $secret doesn't exist"
    fi
  done
  
  return 0
}

# Check database connectivity
check_connectivity() {
  header "Checking Database Connectivity"
  
  primary_pod=$(kubectl get pods -n $NAMESPACE -l postgresql=$CLUSTER_NAME,role=primary -o name 2>/dev/null | cut -d'/' -f2)
  
  if [ -z "$primary_pod" ]; then
    error "No primary PostgreSQL pod found"
    return 1
  fi
  
  echo "Testing connection to primary pod: $primary_pod"
  
  if kubectl exec -it -n $NAMESPACE $primary_pod -- pg_isready -U postgres &> /dev/null; then
    success "Connection to PostgreSQL is successful"
    
    echo "Testing SQL query..."
    query_result=$(kubectl exec -it -n $NAMESPACE $primary_pod -- psql -U postgres -tAc "SELECT 1" 2>/dev/null)
    
    if [ "$query_result" = "1" ]; then
      success "SQL query executed successfully"
    else
      error "Failed to execute SQL query"
    fi
  else
    error "Failed to connect to PostgreSQL"
  fi
}

# Main function
main() {
  echo "=== CloudNativePG Setup Verification ==="
  echo "Date: $(date)"
  
  check_cnpg_crds
  check_operator
  check_pg_cluster
  check_connectivity
  
  echo -e "\nVerification complete. See above for any issues."
}

# Run main function
main
