# Step 01 - Start From The Baseline

Goal: create the learner repository from the production-grade starting point and prove it works before adding automation.

## Before you begin

The step folders in this repository are snapshots, not the exercise. Work in your own GitHub repository and use this repository as a guide and checkpoint.

How to use the workshop:

1. create a dedicated GitHub repository from `steps/01-start`
2. do the work in that repository, not in this workshop repository
3. read the Hoverkraft docs linked in each step before writing YAML
4. use `steps/02-add-ci`, `steps/03-add-cd`, and `steps/argocd-app-of-apps` only as checkpoints after you have tried the step yourself

Important rule:

1. the application code, Dockerfiles, and Helm charts are already in place in `01-start`
2. the workshop delta is mostly under `.github/workflows/`
3. if you think you need to change application code to make CI or CD work, stop and re-check the workflow contract first

Reference docs:

- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/>
- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/github-actions/>
- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/>
- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/ci>
- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/cd>
- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/multi-app>
- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/cicd-release-management/>

## Outcome

At the end of this step, you should have your own GitHub repository based on [steps/01-start](steps/01-start), running locally, with no CI/CD workflow yet.

## Step 1. Create the learner repository

1. Copy the content of [steps/01-start](steps/01-start) into a dedicated GitHub repository.
2. Keep the repository structure as-is.
3. Push it to GitHub on a `main` branch.

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/>
- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/github-actions/>

## Step 2. Validate the local baseline

Run the baseline exactly as provided.

1. Run `make setup`.
2. Run `make ci`.
3. Confirm the application still behaves like a production-grade baseline: Dockerized services, local development flow, and Helm chart in place.

If the local baseline is not green, do not start writing workflows yet.

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/>

## Step 3. Understand what is already solved

Before touching GitHub Actions, be clear about the scope.

What is already done in `01-start`:

1. application code
2. Dockerfiles
3. umbrella Helm chart
4. local development commands

What is intentionally missing:

1. pull request CI
2. mainline CI
3. release preparation
4. deployment workflows

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/>

## Step 4. Confirm the repository shape

This workshop uses the multi-application CI/CD shape.

You have:

1. one Dockerfile per service
2. one `ci` image per service
3. one runtime image per service
4. one umbrella chart that releases the services together

This matters because you should follow the multi-app guide, not the single-app one.

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/multi-app>

## Exit criteria

Before moving to the next step, confirm these points:

1. your repository is based on [steps/01-start](steps/01-start)
2. `make setup` works locally
3. `make ci` works locally
4. there is no `.github/workflows/` CI/CD implementation yet

## If you get stuck

1. compare your repository structure with [steps/01-start](steps/01-start)
2. do not invent new application structure
3. do not start with CD before the baseline is stable
