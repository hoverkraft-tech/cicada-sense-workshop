# Step 08 - Add argocd-app-of-apps (GitOps repository)

Goal: prepare the GitOps delivery repository that will receive the deployment state for `cicada-sense`.

Reference snapshot: [steps/argocd-app-of-apps](steps/argocd-app-of-apps)

## Outcome

At the end of this step, you should have an initialized `argocd-app-of-apps` repository with a scaffolded `cicada-sense` application layout for review apps, UAT, and production.
This is a separate repository from the application repository.

If you want a full repository checkpoint instead of comparing file by file against the template README, use [steps/argocd-app-of-apps](steps/argocd-app-of-apps).

## Step 1. Create the GitOps delivery repository

Before implementing CD in the application repository, create the repository that will receive the deployment state.

In this step, keep these repository boundaries in mind:

1. the application repository is where CI and CD workflows live
2. `argocd-app-of-apps` is where deployment state will be written
3. all commands in this step run in the GitOps repository, not in the application repository

Start from this template:

- <https://github.com/hoverkraft-tech/argocd-app-of-apps-template>

What to do:

1. create your own repository from the template
2. keep the repository in the same GitHub owner or organization if you want to reuse the default deploy contract
3. name it `argocd-app-of-apps` or be ready to update the `deploy-parameters` in later CD workflows
4. open a terminal in `/home/coder/work` and clone the new repository locally:

```bash
git clone git@github.com:<your-org>/argocd-app-of-apps.git
cd argocd-app-of-apps
```

5. run the template initialization command immediately after creating the repository, from the repository root

Do not start editing application deployment files by hand before running the template bootstrap command. The template is responsible for generating the starting structure.

Bootstrap command:

```bash
make init-repo GITHUB_ORG=my-org BASE_DOMAIN=example.com DEV_CLUSTER_URL=https://dev.example.com PROD_CLUSTER_URL=https://prod.example.com
```

Replace the placeholder values with the real GitHub owner and cluster domains for your setup.

Useful options:

1. `REPO_NAME=my-argocd-repo` if the repository name should not default to the current directory name
2. `DRY_RUN=1` to preview the files that would be updated before writing them

This initialization step replaces the repository placeholders and removes the bootstrap script so the repository starts from a clean, usable GitOps state.
Commit that initialized state before moving to the next command:

```bash
git add .
git commit -m "chore: initialize GitOps repository"
git push
```

At this point, you should have one clean commit that represents "template initialized for my org and domains".

Checkpoint: compare your repository root with [steps/argocd-app-of-apps](steps/argocd-app-of-apps) after initialization.

## Step 2. Create the `cicada-sense` application in the GitOps repository

Once the GitOps repository is initialized, scaffold the application layout for this workshop.
Run the command from the root of the GitOps repository you just initialized.

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

After scaffolding, adjust the generated files deliberately. The easiest approach is to compare them with the matching files under [steps/argocd-app-of-apps](steps/argocd-app-of-apps) and align the same fields.

A practical review loop from the GitOps repository root looks like this:

```bash
sed -n '1,200p' dev/apps/review-apps/cicada-sense/template.yml.tpl
sed -n '1,120p' dev/manifests/review-apps/cicada-sense/template.yml.tpl
sed -n '1,200p' prod/apps/uat/cicada-sense/cicada-sense.yml
sed -n '1,120p' prod/manifests/uat/cicada-sense/cicada-sense.yml
sed -n '1,200p' prod/apps/production/cicada-sense/cicada-sense.yml
sed -n '1,120p' prod/manifests/production/cicada-sense/cicada-sense.yml
```

A target state close to this is expected for the application files:

```yaml
# review app template
spec:
   destination:
      namespace: cicada-sense-review
      server: https://dev.example.com
   sources:
      - repoURL: ghcr.io/hoverkraft-sh/cicada-sense/charts/application
         chart: cicada-sense
         helm:
            values: |
               ingress:
                  hosts:
                     - host: cicada-sense-review.example.com
```

```yaml
# uat application
spec:
   destination:
      namespace: cicada-sense-uat
      server: https://prod.example.com
   sources:
      - repoURL: ghcr.io/hoverkraft-sh/cicada-sense/charts/application
         chart: cicada-sense
         helm:
            values: |
               ingress:
                  hosts:
                     - host: cicada-sense-uat.example.com
```

```yaml
# production application
spec:
   destination:
      namespace: cicada-sense-production
      server: https://prod.example.com
   sources:
      - repoURL: ghcr.io/hoverkraft-sh/cicada-sense/charts/application
         chart: cicada-sense
         helm:
            values: |
               ingress:
                  hosts:
                     - host: cicada-sense.example.com
```

At minimum, review these files and fields:

1. `dev/apps/review-apps/cicada-sense/template.yml.tpl`
   - `spec.destination.server`: the dev cluster URL
   - `spec.sources[0].repoURL`: the chart repository reference used for this workshop
   - the review ingress host names under `helm.values.ingress.hosts` and `helm.values.ingress.tls.hosts`
2. `dev/manifests/review-apps/cicada-sense/template.yml.tpl`
   - the review namespace name
   - the matching `app.kubernetes.io/instance` annotation
3. `prod/apps/uat/cicada-sense/cicada-sense.yml`
   - `spec.destination.namespace`: `cicada-sense-uat`
   - `spec.destination.server`: the production cluster URL used for UAT in this workshop
   - the UAT ingress host names
4. `prod/manifests/uat/cicada-sense/cicada-sense.yml`
   - the namespace name
   - the matching `app.kubernetes.io/instance` annotation
5. `prod/apps/production/cicada-sense/cicada-sense.yml`
   - `spec.destination.namespace`: `cicada-sense-production`
   - `spec.destination.server`: the production cluster URL
   - the production ingress host names
6. `prod/manifests/production/cicada-sense/cicada-sense.yml`
   - the namespace name
   - the matching `app.kubernetes.io/instance` annotation

What to leave alone for now:

1. keep `targetRevision` empty where the file says the deploy workflow will update it later
2. do not try to add runtime image values manually in this step
3. do not try to simulate deployment metadata yet; the application deploy workflow will write that later

If you want a simple rule: in this step, you prepare the GitOps file structure, cluster targets, namespaces, and hostnames. The future deploy workflow will fill the release-specific chart revision and image references.

Commit this scaffolded application state before returning to the application repository:

```bash
git add .
git commit -m "feat: scaffold cicada-sense application"
git push
```

Do not try to wire deployment automation yet. In this step, your goal is only to prepare the repository structure that the deployment workflow will update later.

Checkpoint: compare your generated `cicada-sense` folders with the ones under [steps/argocd-app-of-apps](steps/argocd-app-of-apps).

## Step 3. Validate the GitOps repository state

Before you return to the application repository, confirm that the GitOps repository is usable.

Check these points:

1. the template placeholders have been replaced
2. the repository bootstrap is complete
3. the `cicada-sense` review, UAT, and production directories exist
4. the generated files are ready to receive the real chart and image references from the CD workflow
5. the repository history now contains at least one commit for initialization and one for the `cicada-sense` scaffold

This quick check can help before you move on:

```bash
git log --oneline -n 2
```

If you cannot clearly point to those two commits, you likely skipped a checkpoint and should clean that up before moving on.

Read:

- <https://github.com/hoverkraft-tech/argocd-app-of-apps-template>

Dedicated snapshot:

- [steps/argocd-app-of-apps](steps/argocd-app-of-apps)

## Step 4. Know the final repository content

The scaffolded repository is not the final state.

Once you complete [09-add-cd-application-repository.md](09-add-cd-application-repository.md), the application repository deploy workflow writes the desired deployment state into this GitOps repository.

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

Once the GitOps repository is ready, continue with [09-add-cd-application-repository.md](09-add-cd-application-repository.md) to implement CD in the application repository.

## Exit criteria

Before you move on, confirm these points:

1. you created your own `argocd-app-of-apps` repository from the template
2. you ran the template bootstrap command successfully
3. you scaffolded the `cicada-sense` application in that repository
4. the repository now contains review, UAT, and production application directories for `cicada-sense`
5. you committed and pushed the initialized repository state and the scaffolded application state
6. you know which `apps/` and `manifests/` files will be updated by the deployment workflow in the next step

## If you get stuck

1. compare your repository state with the template README, not with the application repository
2. use `DRY_RUN=1` before rerunning template commands
3. do not handcraft the directory layout before running the template commands
4. do not start writing application CD workflows before this repository is ready
