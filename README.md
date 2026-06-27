# Cicada Sense Workshop

This workshop teaches how to add CI/CD to a real application the Hoverkraft way.

You start from a production-grade baseline that already includes the application code, Dockerfiles, and Helm chart. From there, you progressively add GitHub Actions workflows until the repository reaches the CI state of `steps/02-add-ci`, then prepare the GitOps delivery repository, then add the CD workflows that match `steps/03-add-cd`.

For the GitOps repository itself, the dedicated reference snapshot lives in `steps/argocd-app-of-apps`.

## Goal

The goal is not to copy files from one snapshot to another.

The goal is to understand the delivery model and implement it yourself:

1. start from a working multi-application repository
2. add CI that validates pull requests and `main`
3. prepare the `argocd-app-of-apps` GitOps repository for the application
4. add CD that prepares releases and promotes the same built artifacts to review apps, UAT, and production

At the end of the workshop, learners should be able to reproduce the workflow structure on their own repository without depending on the snapshot folders.

## Journey

The workshop is split into four steps.

1. `01-start`: bootstrap the learner repository from the baseline and confirm it works locally
2. `02-add-ci`: add the GitHub Actions CI workflow family
3. `03-add-cd-gitops-repository`: create and initialize the GitOps delivery repository for `cicada-sense`
4. `04-add-cd-application-repository`: add release preparation and deployment workflows in the application repository

The step folders in this repository are reference snapshots. They show the expected destination for each stage, but they are not the exercise itself.

Learners should work in their own GitHub repository, use the Hoverkraft docs to understand the contract, and compare with the snapshots only when they need to verify their result.

The step guide filenames are descriptive on purpose. The `steps/` snapshot folders keep the compact historical names for the application repository checkpoints, while `steps/argocd-app-of-apps` is the dedicated GitOps repository snapshot.

## Where to go next

Start with the step guide that matches your current stage:

1. [01-start.md](01-start.md) - prepare the baseline repository and understand the repository shape
2. [02-add-ci.md](02-add-ci.md) - implement CI in GitHub Actions
3. [03-add-cd-gitops-repository.md](03-add-cd-gitops-repository.md) - prepare the GitOps delivery repository and scaffold `cicada-sense`
4. [04-add-cd-application-repository.md](04-add-cd-application-repository.md) - implement release and deployment workflows

Reference snapshot for the external GitOps repository:

1. `steps/argocd-app-of-apps` - initialized `argocd-app-of-apps` repository scaffolded for `cicada-sense`