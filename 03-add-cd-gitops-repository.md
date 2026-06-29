# Step 03 - Add argocd-app-of-apps (GitOps repository)

Goal: prepare the GitOps delivery repository that will receive the deployment state for `cicada-sense`.

Reference snapshot: [steps/argocd-app-of-apps](steps/argocd-app-of-apps)

## Outcome

At the end of this step, you should have an initialized `argocd-app-of-apps` repository with a scaffolded `cicada-sense` application layout for review apps, UAT, and production.

If you want a full repository checkpoint instead of comparing file by file against the template README, use [steps/argocd-app-of-apps](steps/argocd-app-of-apps).

## Step 1. Create the GitOps delivery repository

Before implementing CD in the application repository, create the repository that will receive the deployment state.

Start from this template:

- <https://github.com/hoverkraft-tech/argocd-app-of-apps-template>

What to do:

1. create your own repository from the template
2. keep the repository in the same GitHub owner or organization if you want to reuse the default deploy contract
3. name it `argocd-app-of-apps` or be ready to update the `deploy-parameters` in later CD workflows
4. run the template initialization command immediately after creating the repository

Bootstrap command:

```bash
make init-repo GITHUB_ORG=my-org BASE_DOMAIN=example.com DEV_CLUSTER_URL=https://dev.example.com PROD_CLUSTER_URL=https://prod.example.com
```

Replace the placeholder values with the real GitHub owner and cluster domains for your setup.

Useful options:

1. `REPO_NAME=my-argocd-repo` if the repository name should not default to the current directory name
2. `DRY_RUN=1` to preview the files that would be updated before writing them

This initialization step replaces the repository placeholders and removes the bootstrap script so the repository starts from a clean, usable GitOps state.

Checkpoint: compare your repository root with [steps/argocd-app-of-apps](steps/argocd-app-of-apps) after initialization.

## Step 2. Create the `cicada-sense` application in the GitOps repository

Once the GitOps repository is initialized, scaffold the application layout for this workshop.

Run:

```bash
make new-app APP_NAME=cicada-sense
```

Useful option:

1. `DRY_RUN=1` to preview the generated files before writing them

This command creates the default review, UAT, and production directories for the application, including:

1. `dev/apps/review-apps/cicada-sense/`
2. `dev/manifests/review-apps/cicada-sense/`
3. `prod/apps/uat/cicada-sense/`
4. `prod/manifests/uat/cicada-sense/`
5. `prod/apps/production/cicada-sense/`
6. `prod/manifests/production/cicada-sense/`

After scaffolding, adjust the generated files with the real chart reference, ingress hosts, namespaces, and any environment-specific values needed for this workshop.

Checkpoint: compare your generated `cicada-sense` folders with the ones under [steps/argocd-app-of-apps](steps/argocd-app-of-apps).

## Step 3. Validate the GitOps repository state

Before you return to the application repository, confirm that the GitOps repository is usable.

Check these points:

1. the template placeholders have been replaced
2. the repository bootstrap is complete
3. the `cicada-sense` review, UAT, and production directories exist
4. the generated files are ready to receive the real chart and image references from the CD workflow

Read:

- <https://github.com/hoverkraft-tech/argocd-app-of-apps-template#initialize-a-repository-created-from-this-template>
- <https://github.com/hoverkraft-tech/argocd-app-of-apps-template#adding-a-new-application>

Dedicated snapshot:

- [steps/argocd-app-of-apps](steps/argocd-app-of-apps)

## Step 4. Know the final repository content

The scaffolded repository is not the final state.

Once you complete [04-add-cd-application-repository.md](04-add-cd-application-repository.md), the application repository deploy workflow writes the desired deployment state into this GitOps repository.

The stable layout stays the same:

```text
argocd-app-of-apps/
├── dev/apps/review-apps/cicada-sense/
├── dev/manifests/review-apps/cicada-sense/
├── prod/apps/uat/cicada-sense/
├── prod/manifests/uat/cicada-sense/
├── prod/apps/production/cicada-sense/
└── prod/manifests/production/cicada-sense/
```

What changes after the first successful deployment:

1. the ArgoCD `Application` manifest under `apps/` points to the released `application` Helm chart revision published by the application repository
2. the target namespace in that `Application` manifest matches the deployed environment:
   - review app: a pull-request-specific namespace
   - UAT: the stable UAT namespace
   - production: the stable production namespace
3. the `Application` metadata carries deployment traceability annotations:
   - `argocd.argoproj.io/application-repository`
   - `argocd.argoproj.io/deployment-id`
4. the Helm values embedded in the `Application` manifest contain the runtime image references for:
   - `.backend.image`
   - `.frontend.image`
   - `.live-data-generator.api.image`
   - `.live-data-generator.ui.image`
5. each of those image references resolves to registry, repository, tag, and digest for the already-built artifacts; deployment reuses promoted artifacts instead of rebuilding them
6. the matching extra manifest under `manifests/` uses the same namespace and instance naming as the `Application` manifest

Treat that as the final checkpoint for the `argocd-app-of-apps` repository. If the deployment workflow does not update those fields, it is not targeting the GitOps repository correctly.

## Next step

Once the GitOps repository is ready, continue with [04-add-cd-application-repository.md](04-add-cd-application-repository.md) to implement CD in the application repository.

## Exit criteria

Before you move on, confirm these points:

1. you created your own `argocd-app-of-apps` repository from the template
2. you ran the template bootstrap command successfully
3. you scaffolded the `cicada-sense` application in that repository
4. the repository now contains review, UAT, and production application directories for `cicada-sense`
5. you know which `apps/` and `manifests/` files will be updated by the deployment workflow in the next step

## If you get stuck

1. compare your repository state with the template README, not with the application repository
2. use `DRY_RUN=1` before rerunning template commands
3. do not start writing application CD workflows before this repository is ready
