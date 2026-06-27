# Review app raw manifests

This folder contains raw Kubernetes manifest templates for review apps deployed in the development cluster.

These files complement the ArgoCD `Application` templates stored in `dev/apps/review-apps/` and are meant for resources that must be rendered per review environment, such as ingress, config maps, or additional workload objects.

Use this folder for temporary preview environment manifests, not for long-lived development resources.
