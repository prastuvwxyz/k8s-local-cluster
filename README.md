# Kubernetes Local Cluster with Kind

This repository contains configuration and scripts for setting up a local Kubernetes cluster using [Kind](https://kind.sigs.k8s.io/) (Kubernetes IN Docker).

## Prerequisites

Before you begin, make sure you have the following tools installed:

- [Docker](https://docs.docker.com/get-docker/)
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Make](https://www.gnu.org/software/make/) (usually pre-installed on most systems)
- [Flux CLI](https://fluxcd.io/docs/installation/) (optional, can be installed using the Makefile)

## Cluster Configuration

The cluster is configured in the `kind-config.yaml` file with:
- 1 control-plane node
- 2 worker nodes
- Port mappings for HTTP (80) and HTTPS (443) on the control-plane node

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

### Directory Structure

The Flux CD configuration is organized as follows:

- `clusters/local-cluster/`: Contains the Flux CD configuration for the local-cluster

### GitOps Workflow

1. Make changes to the Kubernetes manifests in the `clusters/` directory
2. Commit and push the changes to your GitHub repository
3. Flux CD will automatically detect the changes and apply them to your cluster

## Troubleshooting

If you encounter issues:

1. Ensure Docker is running
2. Check if there are any port conflicts (especially for ports 80 and 443)
3. Make sure you have sufficient resources (CPU, memory) for running the cluster
4. For specific Kind errors, refer to the [Kind troubleshooting guide](https://kind.sigs.k8s.io/docs/user/known-issues/)
5. For Flux CD issues, check the Flux logs with `kubectl logs -n flux-system deployment/source-controller` or `kubectl logs -n flux-system deployment/kustomize-controller`
