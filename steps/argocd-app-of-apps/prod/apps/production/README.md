# Production ArgoCD applications

This folder contains ArgoCD `Application` manifests for workloads deployed to the production environment.

Each subfolder usually maps to one application and defines the desired production deployment source, version, destination namespace, and sync policy.

Use this folder only for stable production deployments. Prerelease or validation environments belong elsewhere.
