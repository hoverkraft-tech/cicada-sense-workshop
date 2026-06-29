# Step 02 - Add CI

Goal: starting from [steps/01-start](steps/01-start), implement GitHub Actions CI until you are close to [steps/02-add-ci](steps/02-add-ci).

## Outcome

At the end of this step, your repository should validate pull requests and `main` with the Hoverkraft CI contract for a multi-application repository.

## Step 1. Read the contract before writing YAML

Read these pages first:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/>
- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/ci>
- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/multi-app>
- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/github-actions/>

You are not trying to invent a pipeline. You are implementing an existing contract.

## Step 2. Create the shared CI workflow

Create `.github/workflows/__shared-ci.yml` first.

Your shared workflow should do this, in this order:

1. run repository-wide linting
2. build `backend-ci`, `frontend-ci`, and `live-data-generator-ci`
3. run CI in a matrix for the three applications
4. build runtime images only after CI passes
5. validate the Helm chart with the built runtime images

The important part is the contract and the sequence, not decorative YAML.

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/ci>
- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/multi-app>

## Step 3. Add the pull request entrypoint

Create `.github/workflows/pull-request-ci.yml`.

Rules:

1. trigger on pull requests targeting `main`
2. keep it thin
3. call `__shared-ci.yml`
4. define `concurrency`
5. start from explicit top-level `permissions: {}`
6. grant permissions per job only

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/ci>
- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/github-actions/>

## Step 4. Add the mainline entrypoint

Create `.github/workflows/main-ci.yml`.

Rules:

1. trigger on pushes to `main`
2. keep it thin
3. prune stale preview and runtime image tags
4. call `__shared-ci.yml`
5. regenerate Helm docs after CI succeeds
6. keep permissions explicit and scoped

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/ci>
- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/multi-app>
- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/github-actions/>

## Step 5. Validate CI behavior

Open a pull request and inspect the workflow graph.

Expected pull request behavior:

1. a thin wrapper calls the shared workflow
2. lint runs first
3. CI images are built
4. the matrix runs for backend, frontend, and live-data-generator
5. runtime images are built only after checks pass
6. chart tests run last

Expected `main` behavior after merge:

1. stale image tags are pruned
2. the same CI contract runs again
3. Helm docs are regenerated

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/ci>
- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/github-actions/>

## Step 6. Reach parity with the snapshot

If you want to get close to [steps/02-add-ci](steps/02-add-ci), add the repo-hygiene workflows present in the snapshot:

1. `greetings.yml`
2. `semantic-pull-request.yml`
3. `stale.yml`
4. `need-fix-to-issue.yml`

These are useful, but they are not the core CI objective. The real learning target is the three-file CI family:

1. `__shared-ci.yml`
2. `pull-request-ci.yml`
3. `main-ci.yml`

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/github-actions/>

## Exit criteria

Before moving to the next step, confirm these points:

1. your CI logic lives in `__shared-ci.yml`
2. PR and `main` workflows are thin wrappers
3. CI runs inside dedicated `ci` images
4. chart validation uses the built runtime images
5. your result is close to [steps/02-add-ci](steps/02-add-ci)

## If you get stuck

1. compare one workflow file at a time with [steps/02-add-ci](steps/02-add-ci)
2. do not duplicate logic between PR and `main`
3. if you are changing application code, you are probably solving the wrong problem
