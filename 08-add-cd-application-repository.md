# Step 08 - Add CD (application repository)

Goal: starting from the CI state and a ready GitOps repository, implement release and deployment workflows until you are close to [steps/08-add-cd-application-repository](steps/08-add-cd-application-repository).

## Outcome

At the end of this step, your repository should be able to deploy a review app from a pull request, then prepare a release, create a promotion tag, and deploy the same tagged artifacts to UAT and production through your own GitOps delivery repository.

## Step 1. Prepare the GitHub repository settings

Start this step only after the CI workflows from [steps/06-add-ci](steps/06-add-ci) are green and your separate `argocd-app-of-apps` repository is ready.
In this step, you work in the application repository, not in `argocd-app-of-apps`.

Before writing CD workflows, configure the repository settings they depend on.
For this workshop, these are organization-level GitHub Actions variables and secrets.
The application repository is expected to inherit them from the workshop organization.

Do not recreate them at repository level unless the workshop organizers explicitly tell you to do so.
The useful check here is to confirm that they already exist at organization level. Otherwise, your first workflow runs may fail for missing configuration instead of revealing real CD issues.

In GitHub, the shortest path is usually:

1. open the workshop organization
2. open `Settings`
3. open `Secrets and variables`
4. open `Actions`

Required variables and secrets for this workshop:

1. variable `OCI_REGISTRY`
2. variable `CI_BOT_APP_CLIENT_ID`
3. secret `CI_BOT_APP_PRIVATE_KEY`
4. variable `REVIEW_APPS_URL`
5. variable `UAT_URL`
6. variable `PRODUCTION_URL`

Copy list:

```text
Variables:
OCI_REGISTRY
CI_BOT_APP_CLIENT_ID
REVIEW_APPS_URL
UAT_URL
PRODUCTION_URL

Secrets:
CI_BOT_APP_PRIVATE_KEY
```

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/cd>

## Step 2. Add release preparation

Create `.github/workflows/prepare-release.yml`.

Open a terminal in the application repository root and create the workflow file first:

```bash
mkdir -p .github/workflows
touch .github/workflows/prepare-release.yml
```

Its job is intentionally small:

1. run on pull requests and pushes to `main`
2. prepare release metadata
3. do not deploy anything

A small structure like this is enough:

```yaml
name: Prepare release

on:
  push:
    branches: [main]
  pull_request:
    types: [opened, reopened, synchronize]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

permissions: {}

jobs:
  release:
    uses: hoverkraft-tech/ci-github-publish/.github/workflows/prepare-release.yml@<ref>
    permissions:
      contents: read
      pull-requests: write
```

This workflow exists to keep release intent ready before promotion time.
It should not write to the GitOps repository.

If this file starts looking like a deploy workflow, it has grown beyond its job.

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/cd>

## Step 3. Add the deploy contract

Create `.github/workflows/deploy.yml`.

From the same terminal, create the deploy workflow file:

```bash
touch .github/workflows/deploy.yml
```

This is the core CD workflow. It should:

1. support `workflow_call`
2. support `/deploy` through `issue_comment`
3. receive a `tag` and an `environment`
4. allow review app deployment from a pull request comment
5. reuse already-built runtime images
6. update GitOps state instead of rebuilding during deploy
7. map the three runtime images into the umbrella chart values

A structure close to this works well:

```yaml
name: Deploy

on:
  issue_comment:
    types: [created]
  workflow_call:
    inputs:
      tag:
        required: true
        type: string
      environment:
        required: true
        type: string
    secrets:
      CI_BOT_APP_PRIVATE_KEY:
        required: true

permissions: {}

jobs:
  deploy:
    uses: hoverkraft-tech/ci-github-publish/.github/workflows/deploy-chart.yml@<ref>
    permissions:
      actions: read
      contents: write
      deployments: write
      id-token: write
      issues: write
      packages: write
      pull-requests: write
    secrets:
      oci-registry-password: ${{ secrets.GITHUB_TOKEN }}
      github-app-key: ${{ secrets.CI_BOT_APP_PRIVATE_KEY }}
    with:
      url: ${{ (inputs.environment == 'uat' && vars.UAT_URL) || (inputs.environment == 'production' && vars.PRODUCTION_URL) || vars.REVIEW_APPS_URL }}
      tag: ${{ inputs.tag }}
      environment: ${{ inputs.environment }}
      github-app-client-id: ${{ vars.CI_BOT_APP_CLIENT_ID }}
      deploy-parameters: |
        { "repository": "${{ github.repository_owner}}/argocd-app-of-apps" }
      images: |
        [
          { "name": "backend", "context": ".", "dockerfile": "./docker/backend/Dockerfile", "target": "prod", "platforms": ["linux/amd64"] },
          { "name": "frontend", "context": ".", "dockerfile": "./docker/frontend/Dockerfile", "target": "prod", "platforms": ["linux/amd64"] },
          { "name": "live-data-generator", "context": ".", "dockerfile": "./docker/live-data-generator/Dockerfile", "target": "prod", "platforms": ["linux/amd64"] }
        ]
      chart-values: |
        [
          { "path": ".backend.image", "image": "backend" },
          { "path": ".frontend.image", "image": "frontend" },
          { "path": ".live-data-generator.api.image", "image": "live-data-generator" },
          { "path": ".live-data-generator.ui.image", "image": "live-data-generator" },
          { "path": "deploy.backend.ingress.hosts[0].host", "value": "{{ url }}" },
          { "path": "deploy.frontend.ingress.hosts[0].host", "value": "{{ url }}" }
        ]
```

What to pay attention to in that snippet:

1. the deploy URL changes with the target environment
2. `deploy-parameters.repository` points to `argocd-app-of-apps`
3. the `images` block lists the three runtime images
4. the `chart-values` block maps those images into the umbrella chart values
5. the `chart-values` block also updates the backend and frontend review ingress hosts to `{{ url }}`, so preview deployments resolve to the generated review URL

Be strict about responsibility boundaries:

1. `deploy.yml` is the workflow that writes deployment state to the GitOps repository
2. it should deploy artifacts that CI has already built
3. it should not duplicate release creation logic

Build this workflow around the review app path first. That is the cheapest environment to validate because it proves the contract before you involve release tags or production environments.

Important constraint: the `/deploy` comment flow uses the workflow definition available on `main`. That means `deploy.yml` must be merged to `main` before the pull request comment trigger can be tested reliably.

Match the contract field by field. Do not improvise the inputs, image mapping, or deployment model.

The first environment to prove is the review app flow:

1. merge the CD workflow files to `main` so the `/deploy` workflow exists on the default branch
2. open a new pull request
3. let CI publish the pull-request images
4. trigger deployment with `/deploy`
5. confirm the deployment resolves against `REVIEW_APPS_URL`
6. confirm the deployment updates your `argocd-app-of-apps` repository rather than rebuilding anything

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/cd>

## Step 4. Validate the review app flow

Before promoting anything to UAT or production, validate the preview flow on a pull request.
That pull request should be opened after the CD workflows have already been merged to `main`.

Expected behavior:

1. CI publishes pull-request image tags
2. a `/deploy` comment triggers `deploy.yml`
3. the workflow deploys to the review app URL
4. the deployment also updates the backend and frontend ingress host values to that review URL
5. the deployment reuses the already-built images
6. the desired state is written to your GitOps repository

In the workshop environment, the deployment completion signal depends on the `auto-finish-deploy` workaround added to the GitOps repository in [07-add-cd-gitops-repository.md](07-add-cd-gitops-repository.md). If the deployment stays pending in GitHub, check that workflow first.

If the workflow rebuilds images, or if you only see changes in the application repository, stop there. That means the deploy contract is still wrong.

Inspect the GitOps repository diff after that first review deployment.
Inspect the GitOps repository diff, not the application repository diff.

This quick check can help from a terminal opened in the GitOps repository:

```bash
git pull
git diff HEAD~1..HEAD
```

You should see changes only in the review app slice:

1. `dev/apps/review-apps/cicada-sense/`
2. `dev/manifests/review-apps/cicada-sense/`

What to verify in those changed files:

1. the ArgoCD `Application` manifest now points to the review deployment chart revision
2. the manifest namespace matches the pull request deployment namespace
3. `argocd.argoproj.io/application-repository` and `argocd.argoproj.io/deployment-id` are present
4. the backend, frontend, and live-data-generator image values point to the pull-request artifacts that CI already built

This is the cheapest way to validate the deployment contract before you involve release tags.

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/cd>

## Step 5. Add the promotion workflow

Create `.github/workflows/release.yml`.

From the same terminal, create the release workflow file:

```bash
touch .github/workflows/release.yml
```

Rules:

1. expose a manual `workflow_dispatch`
2. accept `uat` and `production`
3. create the release tag first
4. call `deploy.yml` with that tag
5. promote the same artifact to every environment

A small structure like this is enough:

```yaml
name: Release

on:
  workflow_dispatch:
    inputs:
      environment:
        description: Environment to deploy to
        required: true
        type: choice
        options:
          - uat
          - production

permissions: {}

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: read
    outputs:
      tag: ${{ steps.create-release.outputs.tag }}
    steps:
      - id: create-release
        uses: hoverkraft-tech/ci-github-publish/actions/release/create@<ref>
        with:
          prerelease: ${{ inputs.environment == 'uat' }}

  deploy:
    needs: [release]
    uses: ./.github/workflows/deploy.yml
    permissions:
      actions: read
      contents: write
      deployments: write
      id-token: write
      issues: write
      packages: write
      pull-requests: write
    with:
      tag: ${{ needs.release.outputs.tag }}
      environment: ${{ inputs.environment }}
    secrets:
      CI_BOT_APP_PRIVATE_KEY: ${{ secrets.CI_BOT_APP_PRIVATE_KEY }}
```

Keep this workflow thin. Its job is promotion orchestration, not deployment logic duplication.

If `release.yml` starts to look like a second `deploy.yml`, you are probably duplicating logic that should stay reusable in the deploy workflow.

For this workshop target, UAT is a prerelease and production is not.

Important detail: the published Hoverkraft CD guide is the source of truth. If you compare your result with [steps/08-add-cd-application-repository](steps/08-add-cd-application-repository), you will notice that the CI prerequisite in `release.yml` is still commented out in the snapshot. Treat that as temporary drift in the example step, not as the contract to copy.

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/cicd-release-management/>

## Step 6. Validate UAT, then production

Test promotion in this order:

1. merge your CD workflows to `main`
2. validate the review app flow on a new pull request with `/deploy`
3. run `release.yml` manually for `uat`
4. confirm that a prerelease tag is created
5. confirm that deployment uses the existing tagged images
6. run the same workflow for `production`
7. confirm that production reuses the same promotion model instead of rebuilding

The key success signal is artifact reuse: UAT and production should consume the same promoted images for the same release tag.

Treat UAT as your proof step. Only move to production once the UAT run and the GitOps diff both look correct.

For the GitOps repository content, verify this environment split:

1. `uat` updates only `prod/apps/uat/cicada-sense/` and `prod/manifests/uat/cicada-sense/`
2. `production` updates only `prod/apps/production/cicada-sense/` and `prod/manifests/production/cicada-sense/`
3. both environments point to the release tag created by `release.yml`
4. both environments keep the same backend, frontend, and live-data-generator artifact references for that promoted tag

The same diff check is useful here after each promotion:

```bash
git pull
git diff HEAD~1..HEAD
```

If a workflow behaves unexpectedly because of stale GitHub Actions caches, this cleanup command can help from a terminal authenticated with `gh`:

```bash
gh cache delete --all --succeed-on-no-caches --repo <owner>/cicada-sense
```

When this step is done, open a terminal in the application repository root and commit then push your CD workflow changes:

```bash
git add .github/workflows
git commit -m "feat: add CD workflows"
git push
```

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/cicd-release-management/>

## Step 7. Know what the target snapshot includes

[steps/08-add-cd-application-repository](steps/08-add-cd-application-repository) adds only three workflows on top of [steps/06-add-ci](steps/06-add-ci):

1. `prepare-release.yml`
2. `release.yml`
3. `deploy.yml`

It does not add a dedicated preview cleanup workflow. If you read about `clean-deploy.yml` in the generic docs, treat that as an extra capability, not part of this workshop target.

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/cd>

## Exit criteria

Before you call this step done, confirm these points:

1. review apps can be deployed from a pull request comment
2. release preparation is separate from deployment
3. `release.yml` creates the tag and then calls `deploy.yml`
4. UAT and production reuse the same artifact model
5. deployment updates GitOps state instead of rebuilding images
6. the three CD workflow files in your repository are `prepare-release.yml`, `deploy.yml`, and `release.yml`
7. your latest CD changes are committed and pushed
8. your result is close to [steps/08-add-cd-application-repository](steps/08-add-cd-application-repository)

## If you get stuck

1. compare only the file you are currently working on with [steps/08-add-cd-application-repository](steps/08-add-cd-application-repository)
2. prefer the published contract over snapshot drift
3. if you are rebuilding images during deploy, your flow is wrong
