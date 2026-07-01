# ArgoCD App-of-Apps Repository

<div align="center">
  <img src=".github/logo.svg" width="60px" align="center" alt="Logo for ArgoCD template app-of-apps" />
</div>

---

![GitHub Verified Creator](https://img.shields.io/badge/GitHub-Verified%20Creator-4493F8?logo=data:image/svg%2bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxNiAxNiIgd2lkdGg9IjE2IiBoZWlnaHQ9IjE2IiBmaWxsPSJyZ2IoNjgsIDE0NywgMjQ4KSI+CiAgPHBhdGggZD0ibTkuNTg1LjUyLjkyOS42OGMuMTUzLjExMi4zMzEuMTg2LjUxOC4yMTVsMS4xMzguMTc1YTIuNjc4IDIuNjc4IDAgMCAxIDIuMjQgMi4yNGwuMTc0IDEuMTM5Yy4wMjkuMTg3LjEwMy4zNjUuMjE1LjUxOGwuNjguOTI4YTIuNjc3IDIuNjc3IDAgMCAxIDAgMy4xN2wtLjY4LjkyOGExLjE3NCAxLjE3NCAwIDAgMC0uMjE1LjUxOGwtLjE3NSAxLjEzOGEyLjY3OCAyLjY3OCAwIDAgMS0yLjI0MSAyLjI0MWwtMS4xMzguMTc1YTEuMTcgMS4xNyAwIDAgMC0uNTE4LjIxNWwtLjkyOC42OGEyLjY3NyAyLjY3NyAwIDAgMS0zLjE3IDBsLS45MjgtLjY4YTEuMTc0IDEuMTc0IDAgMCAwLS41MTgtLjIxNUwzLjgzIDE0LjQxYTIuNjc4IDIuNjc4IDAgMCAxLTIuMjQtMi4yNGwtLjE3NS0xLjEzOGExLjE3IDEuMTcgMCAwIDAtLjIxNS0uNTE4bC0uNjgtLjkyOGEyLjY3NyAyLjY3NyAwIDAgMSAwLTMuMTdsLjY4LS45MjhjLjExMi0uMTUzLjE4Ni0uMzMxLjIxNS0uNTE4bC4xNzUtMS4xNGEyLjY3OCAyLjY3OCAwIDAgMSAyLjI0LTIuMjRsMS4xMzktLjE3NWMuMTg3LS4wMjkuMzY1LS4xMDMuNTE4LS4yMTVsLjkyOC0uNjhhMi42NzcgMi42NzcgMCAwIDEgMy4xNyAwWk03LjMwMyAxLjcyOGwtLjkyNy42OGEyLjY3IDIuNjcgMCAwIDEtMS4xOC40ODlsLTEuMTM3LjE3NGExLjE3OSAxLjE3OSAwIDAgMC0uOTg3Ljk4N2wtLjE3NCAxLjEzNmEyLjY3NyAyLjY3NyAwIDAgMS0uNDg5IDEuMThsLS42OC45MjhhMS4xOCAxLjE4IDAgMCAwIDAgMS4zOTRsLjY4LjkyN2MuMjU2LjM0OC40MjQuNzUzLjQ4OSAxLjE4bC4xNzQgMS4xMzdjLjA3OC41MDkuNDc4LjkwOS45ODcuOTg3bDEuMTM2LjE3NGEyLjY3IDIuNjcgMCAwIDEgMS4xOC40ODlsLjkyOC42OGMuNDE0LjMwNS45NzkuMzA1IDEuMzk0IDBsLjkyNy0uNjhhMi42NyAyLjY3IDAgMCAxIDEuMTgtLjQ4OWwxLjEzNy0uMTc0YTEuMTggMS4xOCAwIDAgMCAuOTg3LS45ODdsLjE3NC0xLjEzNmEyLjY3IDIuNjcgMCAwIDEgLjQ4OS0xLjE4bC42OC0uOTI4YTEuMTc2IDEuMTc2IDAgMCAwIDAtMS4zOTRsLS42OC0uOTI3YTIuNjg2IDIuNjg2IDAgMCAxLS40ODktMS4xOGwtLjE3NC0xLjEzN2ExLjE3OSAxLjE3OSAwIDAgMC0uOTg3LS45ODdsLTEuMTM2LS4xNzRhMi42NzcgMi42NzcgMCAwIDEtMS4xOC0uNDg5bC0uOTI4LS42OGExLjE3NiAxLjE3NiAwIDAgMC0xLjM5NCAwWk0xMS4yOCA2Ljc4bC0zLjc1IDMuNzVhLjc1Ljc1IDAgMCAxLTEuMDYgMEw0LjcyIDguNzhhLjc1MS43NTEgMCAwIDEgLjAxOC0xLjA0Mi43NTEuNzUxIDAgMCAxIDEuMDQyLS4wMThMNyA4Ljk0bDMuMjItMy4yMmEuNzUxLjc1MSAwIDAgMSAxLjA0Mi4wMTguNzUxLjc1MSAwIDAgMSAuMDE4IDEuMDQyWiI+PC9wYXRoPgo8L3N2Zz4K)
[![Continuous Integration](https://github.com/hoverkraft-sh/argocd-app-of-apps/actions/workflows/main-ci.yml/badge.svg)](https://github.com/hoverkraft-sh/argocd-app-of-apps/actions/workflows/main-ci.yml)
[![GitHub tag](https://img.shields.io/github/tag/hoverkraft-sh/argocd-app-of-apps?include_prereleases=&sort=semver&color=blue)](https://github.com/hoverkraft-sh/argocd-app-of-apps/releases/)
[![License](https://img.shields.io/badge/License-MIT-blue)](#license)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

This repository serves as the **Single Source of Truth** for all applications and infrastructure components deployed via ArgoCD. It implements the "App-of-Apps" pattern, enabling a scalable and standardized approach to managing Kubernetes deployments across various environments (Review, Development, UAT, Production).

It combines:

- shared infrastructure and cluster-level resources
- environment-specific ArgoCD `Application` definitions
- raw Kubernetes manifests that ArgoCD should sync directly
- scaffold templates used to create a new application layout consistently

**Key Principles:**

- **GitOps Driven:** All changes to the infrastructure and applications are made through Git, reviewed, and then automatically synchronized by ArgoCD.
- **Immutable Deployments:** Configuration and application manifests are versioned and treated as immutable artifacts.
- **Environment Parity:** Strives for consistency across all environments to minimize discrepancies and facilitate smooth promotions.
- **Convention over Configuration:** Standardized folder structures and naming conventions simplify management and reduce errors.

## Overview

The repository follows the ArgoCD app-of-apps pattern. Instead of managing every workload from a single flat list of manifests, root application sets point to environment-specific application definitions and manifests.

This keeps deployments:

- GitOps-driven, with all desired state stored in Git
- consistent across environments through predictable folder conventions
- scalable as new applications and environments are added

In normal operation, changes should come from reviewed pull requests or from external automation that updates deployment definitions after a build or release.

## Repository structure

- `appsets/`: Root `ApplicationSet` resources that register shared and environment-specific deployments.
- `commons/`: Shared resources reused across environments.
- `dev/`: Review and development deployment definitions.
- `prod/`: UAT and production deployment definitions.
- `templates/`: Scaffold templates used by `make new-app`.
- `tools/`: Utility resources for repository operations and supporting infrastructure.
- `values/`: External Helm values files referenced by application definitions when inline values are not appropriate.

Each major folder can carry its own readme with more detailed guidance.

## Development

### Prerequisites

- `make`
- `docker`
- permission to run Docker locally

Repository tooling runs through `make` and Docker.

### Common commands

```sh
make help
make lint
make lint-fix
make new-app APP_NAME=my-app
```


### Linting

`make lint` builds the local linter image from `Dockerfile` and runs repository checks inside Docker.

`make lint-fix` runs the same checks with auto-fixes enabled for supported linters and formatters.

You can scope linting to specific paths by passing them after the target:

```sh
make lint README.md
make lint-fix scripts/create_dev_app.sh
```

## Deployment workflow

1. A change is made in an application source repository.
2. CI builds and publishes the new image and, when relevant, the Helm chart.
3. Automation updates this repository with the new deployment reference.
4. The change is reviewed and merged.
5. ArgoCD detects drift and synchronizes the cluster to match Git.

## Adding a new application

Application names must be kebab-case.

### Scaffold the repository assets

Generate the default review, UAT, and production directories for a new application:

```sh
make new-app APP_NAME=my-app
```

Use `DRY_RUN=1` to preview the generated directories without writing files:

```sh
make new-app APP_NAME=my-app DRY_RUN=1
```

The scaffold creates these directories:

- `dev/apps/review-apps/my-app/`
- `dev/manifests/review-apps/my-app/`
- `prod/apps/uat/my-app/`
- `prod/manifests/uat/my-app/`
- `prod/apps/production/my-app/`
- `prod/manifests/production/my-app/`

### Register the Helm chart in ArgoCD

If the application is deployed from a Helm chart stored in an OCI registry, an administrator may need to register the repository once:

```sh
argocd repo add ghcr.io/[your-org]/[app-name]/charts/application --type helm --name [app-name] --enable-oci --username 'username' --password 'token' --upsert
```

### Adjust generated configuration

After scaffolding, update the generated files with the real chart reference, image tag strategy, ingress hosts, namespaces, and any environment-specific values.

Use `apps/` for ArgoCD `Application` resources, `manifests/` for raw Kubernetes resources, and `values/` for external Helm values files when you do not want to embed overrides inline.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
