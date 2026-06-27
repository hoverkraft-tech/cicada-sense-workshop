# Review app ArgoCD applications

This folder contains ArgoCD `Application` templates for review apps deployed in the development cluster.

Each subfolder usually represents one application and contains templated manifests that external CI workflows render for pull requests or temporary preview environments.

Use this folder when you need ArgoCD to create or update a short-lived review deployment for an application.
