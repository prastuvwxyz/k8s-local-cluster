# Infrastructure Components

This directory contains infrastructure operators and services that provide foundational capabilities for workloads.

## Structure

```
infrastructure/
├── base/                        # Base infrastructure (shared resources)
│   └── kustomization.yaml
└── overlays/
    └── local/                   # Local development configuration
        ├── kustomization.yaml
        └── cloudnative-pg/      # CloudNative PostgreSQL operator
            ├── base/            # Base operator configuration
            └── local/           # Local patches and overrides
```

## Components

### CloudNative PostgreSQL Operator
- Helm release configuration
- Namespace setup
- Local patches for development

## Deployment Order

Infrastructure components are deployed after platform components:
1. Platform Components (CRDs, Helm repos)
2. **Infrastructure Operators** ← You are here
3. Application Workloads
