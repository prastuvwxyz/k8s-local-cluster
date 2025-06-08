# CloudNativePG Operator

This directory contains the configuration for the CloudNativePG operator using a base/overlay pattern.

## Structure

- `base/`: Contains the base configuration for the CloudNativePG operator
- `local/`: Contains environment-specific overrides for local development

## Usage

The operator is deployed using Flux CD via Helm. The HelmRelease references the `cnpg-charts` HelmRepository defined in the `charts/helm-repository` directory.

The CloudNativePG operator manages PostgreSQL clusters in Kubernetes, providing the following features:
- High availability
- Disaster recovery
- Monitoring
- Backups and point-in-time recovery
- Rolling updates

## Local Development Settings

For local development, the following settings are modified:
- `replicaCount`: Set to 1 for minimal resource usage
- `resources.requests`: Reduced memory and CPU requests for local environment
- `resources.limits`: Reduced memory and CPU limits for local environment
- `monitoring.podMonitorEnabled`: Enabled for monitoring in local environment

## Configuration

To modify the configuration:
1. For changes that should apply to all environments, edit the files in the `base/` directory
2. For environment-specific changes, edit or add patches in the respective environment directory (e.g., `local/`)

## Overlays Pattern
- All environment-specific configuration (local, staging, production) is placed in the respective overlay folder (e.g., `local/`).
- The `base/` folder contains reusable, environment-agnostic configuration.
