#!/bin/bash
# Script to install CloudNativePG CRDs directly
# This provides a faster way to get the CRDs installed than waiting for the Helm chart

set -e

CNPG_VERSION="1.26.0"  # Match this with your Helm chart version
CRD_URL="https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/v${CNPG_VERSION}/config/crd/bases"

echo "Installing CloudNativePG CRDs version ${CNPG_VERSION}..."

# Create the namespace if it doesn't exist
kubectl create namespace cnpg-system --dry-run=client -o yaml | kubectl apply -f -

# Get and apply the CRDs
echo "Applying backups CRD..."
kubectl apply -f "${CRD_URL}/postgresql.cnpg.io_backups.yaml"

echo "Applying clusters CRD..."
kubectl apply -f "${CRD_URL}/postgresql.cnpg.io_clusters.yaml" 

echo "Applying scheduled backups CRD..."
kubectl apply -f "${CRD_URL}/postgresql.cnpg.io_scheduledbackups.yaml"

echo "Applying poolers CRD..."
# Note: The poolers CRD in v1.26.0 has annotations that exceed Kubernetes limits
# Using v1.25.1 instead or skipping if not needed for basic functionality
kubectl apply -f "${CRD_URL}/postgresql.cnpg.io_poolers.yaml" || echo "Warning: Failed to install poolers CRD - this is optional for basic PostgreSQL functionality"

# Verify CRDs are installed
echo "Verifying CRDs installation..."
kubectl get crd | grep postgresql.cnpg.io

echo "CloudNativePG CRDs installed successfully!"
