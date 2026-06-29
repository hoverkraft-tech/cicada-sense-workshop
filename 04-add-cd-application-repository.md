# Step 04 - Add CD (application repository)

Goal: starting from the CI state and a ready GitOps repository, implement release and deployment workflows until you are close to [steps/03-add-cd](steps/03-add-cd).

## Outcome

At the end of this step, your repository should be able to deploy a review app from a pull request, then prepare a release, create a promotion tag, and deploy the same tagged artifacts to UAT and production through your own GitOps delivery repository.

## Step 1. Prepare the GitHub repository settings

Before writing CD workflows, configure the repository settings they depend on.

Required variables and secrets for this workshop:

1. variable `OCI_REGISTRY`
2. variable `CI_BOT_APP_CLIENT_ID`
3. secret `CI_BOT_APP_PRIVATE_KEY`
4. variable `REVIEW_APPS_URL`
5. variable `UAT_URL`
6. variable `PRODUCTION_URL`

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/>
- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/cd>
- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/github-actions/>

## Step 2. Add release preparation

Create `.github/workflows/prepare-release.yml`.

Its job is intentionally small:

1. run on pull requests and pushes to `main`
2. prepare release metadata
3. do not deploy anything

This workflow exists to keep release intent ready before promotion time.

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/cd>
- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/multi-app>

## Step 3. Add the deploy contract

Create `.github/workflows/deploy.yml`.

This is the core CD workflow. It should:

1. support `workflow_call`
2. support `/deploy` through `issue_comment`
3. receive a `tag` and an `environment`
4. allow review app deployment from a pull request comment
5. reuse already-built runtime images
6. update GitOps state instead of rebuilding during deploy
7. map the three runtime images into the umbrella chart values

Match the contract field by field. Do not improvise the inputs, image mapping, or deployment model.

The first environment to prove is the review app flow:

1. open a pull request
2. let CI publish the pull-request images
3. trigger deployment with `/deploy`
4. confirm the deployment resolves against `REVIEW_APPS_URL`
5. confirm the deployment updates your `argocd-app-of-apps` repository rather than rebuilding anything

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/cd>
- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/multi-app>
- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/cicd-release-management/>

## Step 4. Validate the review app flow

Before promoting anything to UAT or production, validate the preview flow on a pull request.

Expected behavior:

1. CI publishes pull-request image tags
2. a `/deploy` comment triggers `deploy.yml`
3. the workflow deploys to the review app URL
4. the deployment reuses the already-built images
5. the desired state is written to your GitOps repository

Inspect the GitOps repository diff after that first review deployment.

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

Rules:

1. expose a manual `workflow_dispatch`
2. accept `uat` and `production`
3. create the release tag first
4. call `deploy.yml` with that tag
5. promote the same artifact to every environment

For this workshop target, UAT is a prerelease and production is not.

Important detail: the published Hoverkraft CD guide is the source of truth. If you compare your result with [steps/03-add-cd](steps/03-add-cd), you will notice that the CI prerequisite in `release.yml` is still commented out in the snapshot. Treat that as temporary drift in the example step, not as the contract to copy.

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/cd>
- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/multi-app>
- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/cicd-release-management/>

## Step 6. Validate UAT, then production

Test promotion in this order:

1. validate the review app flow on a pull request
2. merge your CD workflows to `main`
3. run `release.yml` manually for `uat`
4. confirm that a prerelease tag is created
5. confirm that deployment uses the existing tagged images
6. run the same workflow for `production`
7. confirm that production reuses the same promotion model instead of rebuilding

For the GitOps repository content, verify this environment split:

1. `uat` updates only `prod/apps/uat/cicada-sense/` and `prod/manifests/uat/cicada-sense/`
2. `production` updates only `prod/apps/production/cicada-sense/` and `prod/manifests/production/cicada-sense/`
3. both environments point to the release tag created by `release.yml`
4. both environments keep the same backend, frontend, and live-data-generator artifact references for that promoted tag

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/cd>
- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/cicd-release-management/>

## Step 7. Know what the target snapshot includes

[steps/03-add-cd](steps/03-add-cd) adds only three workflows on top of [steps/02-add-ci](steps/02-add-ci):

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
6. your result is close to [steps/03-add-cd](steps/03-add-cd)

## If you get stuck

1. compare only the file you are currently working on with [steps/03-add-cd](steps/03-add-cd)
2. prefer the published contract over snapshot drift
3. if you are rebuilding images during deploy, your flow is wrong
