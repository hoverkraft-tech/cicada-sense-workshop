# Production and UAT environments

This folder contains the GitOps definitions used to deploy the long-lived `uat` and `production` environments.

## Purpose

Use this folder for environment-specific resources that are promoted beyond temporary review deployments. It groups both ArgoCD `Application` definitions and raw Kubernetes manifests for the production delivery flow.

## Structure

- `1_manifests.yaml`: Registers manifest-based deployments managed from `prod/manifests/`.
- `2_apps.yaml`: Registers ArgoCD applications managed from `prod/apps/`.
- `apps/uat/`: ArgoCD `Application` manifests for the user acceptance testing environment.
- `apps/production/`: ArgoCD `Application` manifests for the production environment.
- `manifests/uat/`: Raw Kubernetes manifests applied to the UAT environment.
- `manifests/production/`: Raw Kubernetes manifests applied to the production environment.

## Guidance

Keep UAT and production resources separated in their dedicated subfolders so release validation and production rollout stay explicit.

Use `apps/` for ArgoCD `Application` resources and `manifests/` for raw Kubernetes objects that ArgoCD should sync directly.
