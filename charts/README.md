# Charts Directory

This directory contains Helm chart repositories and Custom Resource Definitions (CRDs) used in the Kubernetes cluster.

## Structure

- `helm-repository/`: Contains Helm repository definitions
  - `cnpg-charts.yaml`: HelmRepository resource for CloudNativePG charts
  - `bitnami-charts.yaml`: HelmRepository resource for Bitnami charts
  - `kustomization.yaml`: Kustomization file for the helm repositories

- `crds/`: Contains Custom Resource Definitions that can be directly applied to the cluster
  - `kustomization.yaml`: Kustomization file for the CRDs

## Helm Repositories

The Helm repositories defined in this directory are used by the HelmRelease resources throughout the project. For example, the CloudNativePG operator HelmRelease in `infrastructure/operator/cnpg/base/helm-release.yaml` references the `cnpg-charts` HelmRepository.

## Usage

The charts directory is applied to the cluster through the Flux CD configuration:

1. The Flux Kustomization resource in `clusters/local/charts.yaml` refers to this directory
2. Flux applies the resources defined in this directory
3. The Helm repositories become available for HelmRelease resources to use

## Adding a New Helm Repository

To add a new Helm repository:

1. Create a new file in the `helm-repository/` directory (e.g., `new-repo-charts.yaml`)
2. Define a HelmRepository resource in the file
3. Add the file to the `helm-repository/kustomization.yaml`
