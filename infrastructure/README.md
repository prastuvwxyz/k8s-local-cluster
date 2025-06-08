# Infrastructure Components

This directory contains infrastructure operators and services that provide foundational capabilities for apps.

## Structure

```
infrastructure/
└── cloudnative-pg/
    ├── base/      # Base operator configuration
    └── local/     # Local patches and overrides
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
3. Applications

## Overlays Pattern
- All environment-specific configuration (local, staging, production) is placed in the respective overlay folder (e.g., `local/`).
- The `base/` folder contains reusable, environment-agnostic configuration.
