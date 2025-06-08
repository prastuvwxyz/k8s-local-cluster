#!/bin/bash
# Script to check if required CRDs are available
# Usage: ./check-crds.sh

# Check if CloudNativePG CRDs are available
check_cnpg_crds() {
  echo "Checking CloudNativePG CRDs..."
  
  kubectl get crd clusters.postgresql.cnpg.io &> /dev/null
  if [ $? -eq 0 ]; then
    echo "✅ CloudNativePG CRDs are available"
    return 0
  else
    echo "❌ CloudNativePG CRDs are not available yet"
    return 1
  fi
}

# Check if Prometheus Operator CRDs are available
check_prometheus_crds() {
  echo "Checking Prometheus Operator CRDs..."
  
  kubectl get crd servicemonitors.monitoring.coreos.com &> /dev/null
  if [ $? -eq 0 ]; then
    echo "✅ Prometheus ServiceMonitor CRD is available"
    return 0
  else
    echo "⚠️ Prometheus ServiceMonitor CRD is not available - monitoring will be limited"
    return 1
  fi
}

# Main function
main() {
  echo "Checking required CRDs for deployment..."
  
  # Check CloudNativePG CRDs
  for i in {1..10}; do
    check_cnpg_crds && break
    echo "Waiting for CloudNativePG CRDs to be available (attempt $i/10)..."
    sleep 15
  done
  
  if ! check_cnpg_crds; then
    echo "❌ CloudNativePG CRDs are still not available after multiple attempts"
    echo "Try running 'kubectl get crds | grep cnpg' to see if they're installed"
    echo "You may need to reinstall the CloudNativePG operator"
    exit 1
  fi
  
  # Check Prometheus CRDs but continue if not available
  check_prometheus_crds
  
  echo "Ready to deploy PostgreSQL resources"
}

# Run main function
main
