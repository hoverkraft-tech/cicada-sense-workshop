apiVersion: v1
kind: Namespace
metadata:
  name: __APP_NAME__-review # Will be updated by deploy workflow
  annotations:
    app.kubernetes.io/instance: __APP_NAME__-review # Will be updated by deploy workflow
    argocd.argoproj.io/sync-options: Prune=true
    argocd.argoproj.io/sync-wave: "0"