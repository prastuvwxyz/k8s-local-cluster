# Kubernetes Local Cluster with GitOps

This repository contains a production-ready local Kubernetes development environment using:
- **[Kind](https://kind.sigs.k8s.io/)** - Kubernetes IN Docker for local clusters
- **[Flux CD](https://fluxcd.io/)** - GitOps continuous delivery
- **[Telepresence](https://www.telepresence.io/)** - Local development proxy
- **[CloudNative PostgreSQL](https://cloudnative-pg.io/)** - PostgreSQL operator

## GitOps Architecture

This repository follows Kubernetes GitOps best practices with a clear separation of concerns:

```
k8s-local-cluster/
├── clusters/local/                    # Flux CD configurations
│   ├── bootstrap.yaml                # OCI repository and sync setup
│   ├── platform.yaml                 # Platform component deployment
│   ├── infrastructure.yaml           # Infrastructure operator deployment  
│   └── apps.yaml                     # Application deployment
├── platform/                         # Platform components (foundational)
│   ├── base/custom-resource-definitions/  # CRDs for operators
│   ├── base/helm-repositories/            # Third-party chart repos
│   └── overlays/local/                    # Local environment config
├── infrastructure/                   # Infrastructure operators & services
│   ├── cloudnative-pg/               # CloudNativePG operator config
│   │   ├── base/                     # Base operator config
│   │   └── local/                    # Local patches/overrides
├── apps/                             # Application workloads
│   └── database/                     # Database workloads (e.g. PostgreSQL)
│       └── postgresql/
│           ├── base/                 # Base PostgreSQL cluster config
│           └── local/                # Local patches, secrets, monitoring
└── scripts/                          # Development and management scripts
```

### Kustomize Overlays Pattern
- All environment-specific configuration (local, staging, production) is placed in the respective `local/`, `staging/`, or `production/` overlay folders under each domain (platform, infrastructure, apps).
- The `base/` folder contains reusable, environment-agnostic configuration.

### GitOps Workflow
1. Make changes to the Kubernetes manifests in the `clusters/`, `infrastructure/`, or `apps/` directories
2. Commit and push the changes to your GitHub repository
3. Flux CD will automatically detect the changes and apply them to your cluster

## Usage

This repository provides a Makefile with various targets to manage your Kind cluster:

### View Available Commands

```bash
make help
```

This will display all available commands organized by category:
- Environment Management
- Tools Management
- Cluster Management
- Flux CD Management
- Telepresence Management
- Image Management

### Check Required Tools

```bash
make check-tools
```

This will check if all required tools (kind, kubectl, kustomize, flux) are installed and display their versions.

### Set Up the Complete Environment

```bash
make up
```

This will set up the complete environment by:
1. Creating a new Kind cluster
2. Preloading FluxCD images
3. Preloading Telepresence images
4. Bootstrapping Flux CD
5. Connecting Telepresence

### Tear Down the Environment

```bash
make down
```

This will tear down the complete environment by:
1. Disconnecting Telepresence
2. Deleting the Kind cluster

### Create a Cluster

```bash
make create-cluster
```

This will create a new Kind cluster named `local` using the configuration in `kind-config.yaml`.

### Delete the Cluster

```bash
make delete-cluster
```

### List All Kind Clusters

```bash
make get-clusters
```

### Get Cluster Information

```bash
make cluster-info
```

### List Nodes in the Cluster

```bash
make get-nodes
```

### List Pods in the Cluster

```bash
make get-pods
```

### Install Kubernetes Dashboard

```bash
make install-dashboard
```

After installing the dashboard, follow the instructions printed in the terminal to access it.

### Flux CD Commands

For Flux CD related commands, see the [Flux CD Integration](#flux-cd-integration) section below:

```bash
make install-flux-cli         # Install Flux CLI
make bootstrap-flux           # Bootstrap Flux CD with GitHub repository
make flux-status              # Check Flux status
make create-flux-source       # Create a Flux source for the GitHub repository
make create-flux-kustomization # Create a Flux kustomization for the repository
```

## Customization

You can customize the cluster configuration by editing the `kind-config.yaml` file. For example, you can:

- Change the number of worker nodes
- Modify port mappings
- Add persistent volume configurations
- Configure networking options

For more information on Kind configuration options, refer to the [Kind documentation](https://kind.sigs.k8s.io/docs/user/configuration/).

## Flux CD Integration

This repository includes integration with [Flux CD](https://fluxcd.io/), a GitOps tool for Kubernetes. Flux CD allows you to declaratively manage Kubernetes resources using Git as the source of truth.

### Install Flux CLI

```bash
make install-flux-cli
```

This will install the Flux CLI on your system.

### Bootstrap Flux CD

```bash
make bootstrap-flux
```

This will bootstrap Flux CD with your GitHub repository. It will:
1. Create the necessary Flux components in your cluster
2. Configure Flux to watch your GitHub repository
3. Deploy the sample application (podinfo) to your cluster

### Check Flux Status

```bash
make flux-status
```

This will show the status of all Flux resources in your cluster.

### Create a Flux Source

```bash
make create-flux-source
```

This will create a Flux source for your GitHub repository.

### Create a Flux Kustomization

```bash
make create-flux-kustomization
```

This will create a Flux kustomization for your repository.

## Directory Structure

The repository is organized following the GitOps and Kustomize base/overlay pattern:

```
k8s-local-cluster/
├── clusters/local/                    # Flux CD configurations for local cluster
│   ├── bootstrap.yaml                # OCI repository and sync setup
│   ├── platform.yaml                 # Platform component deployment
│   ├── infrastructure.yaml           # Infrastructure operator deployment  
│   └── apps.yaml                     # Application deployment
├── platform/                         # Platform components (foundational)
│   ├── base/custom-resource-definitions/  # CRDs for operators
│   ├── base/helm-repositories/            # Third-party chart repos
│   └── overlays/local/                    # Local environment config
├── infrastructure/                   # Infrastructure operators & services
│   ├── cloudnative-pg/               # CloudNativePG operator config
│   │   ├── base/                     # Base operator config
│   │   └── local/                    # Local patches/overrides
├── apps/                             # Application workloads
│   └── database/                     # Database workloads (e.g. PostgreSQL)
│       └── postgresql/
│           ├── base/                 # Base PostgreSQL cluster config
│           └── local/                # Local patches, secrets, monitoring
└── scripts/                          # Development and management scripts
```

### Kustomize Overlays Pattern
- All environment-specific configuration (local, staging, production) is placed in the respective `local/`, `staging/`, or `production/` overlay folders under each domain (platform, infrastructure, apps).
- The `base/` folder contains reusable, environment-agnostic configuration.

### GitOps Workflow
1. Make changes to the Kubernetes manifests in the `clusters/`, `infrastructure/`, or `apps/` directories
2. Commit and push the changes to your GitHub repository
3. Flux CD will automatically detect the changes and apply them to your cluster

## CloudNativePG

This repository includes support for running PostgreSQL using the CloudNativePG operator.

### Preload CloudNativePG Images

```bash
make preload-cnpg
```

This will preload the CloudNativePG operator and PostgreSQL images into your Kind cluster.

### Install CloudNativePG Operator

```bash
make install-cnpg
```

This will install the CloudNativePG operator in your cluster in the `cnpg-system` namespace.

### Deploy PostgreSQL with 1 Replica

```bash
make deploy-postgres
```

This will deploy a PostgreSQL instance with 1 replica in the `database` namespace.

### Check CloudNativePG Status

```bash
make cnpg-status
```

This will show the status of the CloudNativePG operator and PostgreSQL instances.

### Connecting to PostgreSQL

```bash
# Connect to PostgreSQL
kubectl -n database exec -it postgres-cluster-1 -- psql -U postgres

# Get the connection string
kubectl get secrets -n database postgres-cluster-app -o jsonpath='{.data.uri}' | base64 -d
```

## Troubleshooting

If you encounter issues:

1. Ensure Docker is running
2. Check if there are any port conflicts (especially for ports 80 and 443)
3. Make sure you have sufficient resources (CPU, memory) for running the cluster
4. For specific Kind errors, refer to the [Kind troubleshooting guide](https://kind.sigs.k8s.io/docs/user/known-issues/)
5. For Flux CD issues, check the Flux logs with `kubectl logs -n flux-system deployment/source-controller` or `kubectl logs -n flux-system deployment/kustomize-controller`
6. For PostgreSQL issues, check the CloudNativePG operator logs with `kubectl logs -n cnpg-system deployment/cnpg-controller-manager` and PostgreSQL pod logs with `kubectl logs -n database postgres-cluster-1`
