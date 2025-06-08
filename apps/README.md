# Applications

This directory contains application components for the Kubernetes cluster.

## Database

The `database` directory contains PostgreSQL database configurations managed by the CloudNativePG operator:

### Base Configuration

The `database/base` directory contains the base configuration for PostgreSQL:

- `namespace.yaml`: Creates the namespace for the PostgreSQL database
- `cluster.yaml`: Configures the PostgreSQL cluster with 1 replica
- `kustomization.yaml`: Kustomize configuration to deploy all the above resources

### Local Environment Configuration

The `database/local` directory contains environment-specific overrides for the local development environment:

- `postgres-overrides.yaml`: Contains environment-specific settings for the local environment
- `kustomization.yaml`: Kustomize configuration that patches the base configuration with local overrides

The PostgreSQL cluster is managed by the CloudNativePG operator, providing features like:

- High availability
- Disaster recovery
- Monitoring
- Backups and point-in-time recovery
- Rolling updates
