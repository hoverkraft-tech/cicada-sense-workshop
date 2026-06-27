---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cicada-sense-review # Will be updated by deploy workflow
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "1"
    argocd.argoproj.io/application-repository: cicada-sense
    argocd.argoproj.io/environment: "review"
  labels:
    layer: applications
    service: cicada-sense
    component: main
    environment: dev
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  destination:
    namespace: cicada-sense-review # Will be updated by deploy workflow
    server: https://dev.example.com
  syncPolicy:
    syncOptions:
      - CreateNamespace=false
      - ServerSideApply=true
      - SkipDryRunOnMissingResource=true
    automated:
      prune: true
      selfHeal: true
  sources:
    - repoURL: ghcr.io/hoverkraft-sh/cicada-sense/charts/application
      targetRevision: "" # Will be updated by deploy workflow
      chart: cicada-sense
      helm:
        values: |
          ingress:
            enabled: true
            className: "traefik"
            annotations:
              cert-manager.io/cluster-issuer: letsencrypt
            hosts:
              - host: cicada-sense-review.example.com # Will be updated by deploy workflow
                paths:
                  - path: /
                    pathType: ImplementationSpecific
            tls:
              - secretName: cicada-sense-tls
                hosts:
                  - cicada-sense-review.example.com # Will be updated by deploy workflow