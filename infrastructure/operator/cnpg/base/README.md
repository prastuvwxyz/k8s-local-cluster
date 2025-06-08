# Base Configuration

This directory contains the base configuration for the CloudNativePG operator.

## Files

- `namespace.yaml`: Creates the `cnpg-system` namespace for the CloudNativePG operator
- `helm-release.yaml`: Defines the HelmRelease resource for installing the CloudNativePG operator
- `kustomization.yaml`: Kustomization file that includes the namespace and HelmRelease

## Purpose

The base configuration provides a shared foundation that can be customized for different environments (local, staging, production) using Kustomize overlays. This approach follows the GitOps pattern and allows for:

- Configuration reuse
- Environment-specific customization
- Clear separation of base and environment-specific settings

## Important Notes

- The base configuration is not meant to be directly applied to the cluster. Instead, it should be referenced by environment-specific overlays
- Changes to the base configuration affect all environments that reference it
- Environment-specific settings should be defined in the respective environment overlay (e.g., `local/`)
