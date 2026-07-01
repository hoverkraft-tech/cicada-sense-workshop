---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: __APP_NAME__-review # Will be updated by deploy workflow
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "1"
    argocd.argoproj.io/application-repository: __APP_NAME__
    argocd.argoproj.io/environment: "review"
  labels:
    layer: applications
    service: __APP_NAME__
    component: main
    environment: dev
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  destination:
    namespace: __APP_NAME__-review # Will be updated by deploy workflow
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
    - repoURL: ghcr.io/hoverkraft-sh/__APP_NAME__/charts/application
      targetRevision: "" # Will be updated by deploy workflow
      chart: __APP_NAME__
      helm:
        values: |
          ingress:
            enabled: true
            className: "traefik"
            annotations:
              cert-manager.io/cluster-issuer: letsencrypt
            hosts:
              - host: __APP_NAME__-review.example.com # Will be updated by deploy workflow
                paths:
                  - path: /
                    pathType: ImplementationSpecific
            tls:
              - secretName: __APP_NAME__-tls
                hosts:
                  - __APP_NAME__-review.example.com # Will be updated by deploy workflow