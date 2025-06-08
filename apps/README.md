# Applications

This directory contains applications that run on the Kubernetes cluster.

## Structure

```
apps/
└── database/
    └── postgresql/
        ├── base/      # Base PostgreSQL cluster configuration
        └── local/     # Local patches, secrets, monitoring, and overrides
```

## Components

### PostgreSQL Database
- **Location**: `database/postgresql/`
- **Purpose**: Production-ready PostgreSQL database cluster
- **Features**:
  - Automated backups and scheduled backups
  - Monitoring with ServiceMonitor
  - Custom metrics collection
  - User management and secrets
  - High availability configuration

## Overlays Pattern
- All environment-specific configuration (local, staging, production) is placed in the respective overlay folder (e.g., `local/`).
- The `base/` folder contains reusable, environment-agnostic configuration.

## Deployment Order

Applications are deployed last in the GitOps flow:
1. Platform Components (CRDs, Helm repos)
2. Infrastructure Operators
3. **Applications** ← You are here

## Usage

The PostgreSQL database provides:
- Primary database service for applications
- Automated backup and recovery
- Monitoring and observability
- Development-friendly local configuration
