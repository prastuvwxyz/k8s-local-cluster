# Platform Components

This directory contains foundational platform components including Custom Resource Definitions (CRDs) and Helm repositories.

## Structure

```
platform/
├── base/                                # Base platform components
│   ├── custom-resource-definitions/     # CRDs for operators and extensions
│   ├── helm-repositories/              # Helm chart repositories
│   └── kustomization.yaml
└── overlays/
    └── local/                          # Local development overrides
        └── kustomization.yaml
```

## Components

### Custom Resource Definitions (CRDs)
- CloudNative PostgreSQL CRDs
- Other operator CRDs

### Helm Repositories
- CloudNative PostgreSQL Helm charts
- Other third-party chart repositories

## Deployment Order

Platform components are deployed first in the GitOps flow:
1. **Platform Components** (CRDs, Helm repos) 
2. Infrastructure Operators
3. Application Workloads
