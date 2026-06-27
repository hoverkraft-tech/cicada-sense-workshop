# Helm values files

This folder stores Helm values files used by applications deployed from this repository.

Use it for reusable or environment-specific overrides that should stay separate from the chart source, such as image tags, ingress settings, resource limits, or feature flags.

## Guidance

- Keep values files scoped clearly by application and environment.
- Put ArgoCD `Application` resources in `dev/apps/` or `prod/apps/`, not here.
- Put raw Kubernetes manifests in `dev/manifests/` or `prod/manifests/`, not here.

This folder is useful when an application definition references external Helm values instead of embedding all overrides inline.
