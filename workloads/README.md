# Application Workloads

This directory contains application workloads that run on the Kubernetes cluster.

## Structure

```
workloads/
├── base/                          # Base workload configurations
│   └── kustomization.yaml
└── overlays/
    └── local/                     # Local development configuration
        ├── kustomization.yaml
        └── postgresql-database/   # PostgreSQL database workload
            ├── base/              # Base database configuration
            └── local/             # Local patches and secrets
```

## Components

### PostgreSQL Database
- **Location**: `overlays/local/postgresql-database/`
- **Purpose**: Production-ready PostgreSQL database cluster
- **Features**:
  - Automated backups and scheduled backups
  - Monitoring with ServiceMonitor
  - Custom metrics collection
  - User management and secrets
  - High availability configuration

## Deployment Order

Workloads are deployed last in the GitOps flow:
1. Platform Components (CRDs, Helm repos)
2. Infrastructure Operators
3. **Application Workloads** ← You are here

## Usage

The PostgreSQL database provides:
- Primary database service for applications
- Automated backup and recovery
- Monitoring and observability
- Development-friendly local configuration
