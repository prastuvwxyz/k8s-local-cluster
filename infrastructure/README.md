# Infrastructure Components

This directory contains infrastructure components for the Kubernetes cluster.

## Operator

The `operator` directory contains Kubernetes operators that provide specific functionality to the cluster:

### CloudNativePG (cnpg)

The CloudNativePG operator is located in the `operator/cnpg` directory and includes:

- `namespace.yaml`: Creates the namespace for the CloudNativePG operator
- `helm-repository.yaml`: Configures the Helm repository for CloudNativePG 
- `helm-release.yaml`: Deploys the CloudNativePG operator using Helm
- `kustomization.yaml`: Kustomize configuration to deploy all the above resources

The CloudNativePG operator manages PostgreSQL clusters in Kubernetes, providing features like:

- High availability
- Disaster recovery
- Monitoring
- Backups and point-in-time recovery
- Rolling updates
