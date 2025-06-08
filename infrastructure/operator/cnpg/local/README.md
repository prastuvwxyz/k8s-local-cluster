# Local Environment Configuration

This directory contains local environment-specific overrides for the CloudNativePG operator.

## Files

- `helm-release-patch.yaml`: Patches the HelmRelease resource with settings specific to the local environment
  - Enables pod monitoring
  - Sets resource limits for local development
  - Sets replica count for the controller
- `kustomization.yaml`: Kustomization file that references the base configuration and applies local patches

## Usage

When deploying to the local environment, this directory's kustomization is used instead of directly applying the base configuration. This allows for environment-specific customization without modifying the base files.

## Applying Configuration

To apply this configuration directly:

```bash
kubectl kustomize infrastructure/operator/cnpg/local | kubectl apply -f -
```

Or using the Makefile:

```bash
make install-cnpg
```
