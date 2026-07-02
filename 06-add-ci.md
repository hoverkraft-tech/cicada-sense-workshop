# Step 06 - Add CI

Goal: starting from [steps/05-start](steps/05-start), implement GitHub Actions CI until you are close to [steps/06-add-ci](steps/06-add-ci).

## Outcome

At the end of this step, your repository should validate pull requests and `main` with the Hoverkraft CI contract for a multi-application repository.
The core result is three workflow files: one reusable workflow and two thin entrypoints.

## Step 1. Read the contract before writing YAML

Read these pages first:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/multi-app>

You are not trying to invent a pipeline. You are implementing an existing contract.

Read those pages first. Then, later in this step, this order usually works best:

1. `__shared-ci.yml` first, with the job order defined clearly
2. `pull-request-ci.yml` next, as a thin wrapper around the shared workflow
3. `main-ci.yml` after that, as the second thin wrapper
4. a pull request last, to inspect the workflow graph before comparing with the snapshot

## Step 2. Create the shared CI workflow

Create `.github/workflows/__shared-ci.yml` first.
Make this the only file that contains the real CI job sequence.

Open a terminal in the application repository root and create the workflow file first:

```bash
mkdir -p .github/workflows
touch .github/workflows/__shared-ci.yml
```

Think of this file as the source of truth for CI behavior. If you later find yourself copying jobs into `pull-request-ci.yml` or `main-ci.yml`, stop and move that logic back here.

In this workshop target, `__shared-ci.yml` is easiest to understand as four jobs, in this order:

1. `build-ci`: prepares the CI container images used by later checks
2. `continuous-integration`: runs the application checks in a matrix for `backend`, `frontend`, and `live-data-generator`
3. `build`: builds the deployable runtime images only after all CI checks pass
4. `tests-charts`: validates the Helm chart with the runtime images produced earlier

To keep the workshop CI simpler and faster, do not add a dedicated top-level linter job. Linting stays inside the shared `continuous-integration` flow instead of becoming a separate stage in the workflow graph.

What each job needs to configure:

A minimal workflow header first:

```yaml
name: Shared - Continuous Integration for common tasks

on:
  workflow_call:

permissions: {}
```

Then add the jobs one by one.

`build-ci`:

```yaml
jobs:
  build-ci:
    uses: hoverkraft-tech/ci-github-container/.github/workflows/docker-build-images.yml@<ref>
    permissions:
      contents: read
      packages: write
      issues: read
      pull-requests: read
      id-token: write
    with:
      oci-registry: ${{ vars.OCI_REGISTRY }}
      sign: false
      images: |
        [
          {
            "name": "backend-ci",
            "context": ".",
            "dockerfile": "./docker/backend/Dockerfile",
            "target": "ci",
            "platforms": ["linux/amd64"]
          },
          {
            "name": "frontend-ci",
            "context": ".",
            "dockerfile": "./docker/frontend/Dockerfile",
            "target": "ci",
            "platforms": ["linux/amd64"]
          },
          {
            "name": "live-data-generator-ci",
            "context": ".",
            "dockerfile": "./docker/live-data-generator/Dockerfile",
            "target": "ci",
            "platforms": ["linux/amd64"]
          }
        ]
    secrets:
      oci-registry-password: ${{ secrets.GITHUB_TOKEN }}
```

`continuous-integration`:

```yaml
  continuous-integration:
    name: Continuous Integration - ${{ matrix.application }}
    uses: hoverkraft-tech/ci-github-nodejs/.github/workflows/continuous-integration.yml@<ref>
    needs: build-ci
    permissions:
      contents: read
      id-token: write
      pull-requests: write
      security-events: write
      packages: read
    strategy:
      fail-fast: false
      matrix:
        include:
          - application: backend
            image: backend-ci
            path: ./application/monitoring-workspace/backend
          - application: frontend
            image: frontend-ci
            path: ./application/monitoring-workspace/frontend
          - application: live-data-generator
            image: live-data-generator-ci
            path: ./application/live-data-generator
    with:
      dependency-review: false
      working-directory: /usr/src/app
      container: |
        {
          "image": ${{ toJSON(fromJSON(needs.build-ci.outputs.built-images)[matrix.image].images[0]) }},
          "credentials": {
            "username": ${{ toJson(github.repository_owner) }}
          },
          "pathMapping": {
            "/usr/src/app": "${{ matrix.path }}"
          }
        }
    secrets:
      container-password: ${{ secrets.GITHUB_TOKEN }}
```

Set `dependency-review: false` here for the workshop. The reusable Node.js CI workflow enables dependency review by default, but this workshop does not configure that check and should keep the CI example focused on the lint, typecheck, test, and scan stages you have already wired.

`build`:

```yaml
  build:
    needs: continuous-integration
    uses: hoverkraft-tech/ci-github-container/.github/workflows/docker-build-images.yml@<ref>
    permissions:
      contents: read
      packages: write
      issues: read
      pull-requests: read
      id-token: write
    with:
      oci-registry: ${{ vars.OCI_REGISTRY }}
      sign: false
      images: |
        [
          {
            "name": "backend",
            "context": ".",
            "dockerfile": "./docker/backend/Dockerfile",
            "target": "prod",
            "platforms": ["linux/amd64"]
          },
          {
            "name": "frontend",
            "context": ".",
            "dockerfile": "./docker/frontend/Dockerfile",
            "target": "prod",
            "platforms": ["linux/amd64"]
          },
          {
            "name": "live-data-generator",
            "context": ".",
            "dockerfile": "./docker/live-data-generator/Dockerfile",
            "target": "prod",
            "platforms": ["linux/amd64"]
          }
        ]
    secrets:
      oci-registry-password: ${{ secrets.GITHUB_TOKEN }}
```

`tests-charts`:

```yaml
  tests-charts:
    name: Tests - Charts
    runs-on: ubuntu-latest
    needs: build
    permissions:
      contents: read
      packages: read
    steps:
      - name: Test helm charts
        uses: hoverkraft-tech/ci-github-container/actions/helm/test-chart@<ref>
        with:
          helm-set: |
            backend.image=${{ fromJSON(needs.build.outputs.built-images).backend.images[0] }}
            frontend.image=${{ fromJSON(needs.build.outputs.built-images).frontend.images[0] }}
            live-data-generator.api.image=${{ fromJSON(needs.build.outputs.built-images)['live-data-generator'].images[0] }}
            live-data-generator.ui.image=${{ fromJSON(needs.build.outputs.built-images)['live-data-generator'].images[0] }}
            global.imagePullSecrets[0].name=regcred
          oci-registry: ${{ vars.OCI_REGISTRY }}
          oci-registry-password: ${{ github.token }}
```

What to pay attention to in those snippets:

1. `build-ci` prepares only the three `*-ci` images.
2. `continuous-integration` depends on `build-ci` and maps each application path to its matching CI image.
3. `build` depends on `continuous-integration` and prepares only the three runtime images.
4. `tests-charts` depends on `build` and reuses those built images through `helm-set`.

If you want the exact pinned workflow and action versions, copy them from [steps/06-add-ci/.github/workflows/__shared-ci.yml](steps/06-add-ci/.github/workflows/__shared-ci.yml).

The important part is the contract and the sequence, not decorative YAML.

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/golden-paths/application/ci-cd/github/multi-app>

## Step 3. Add the pull request entrypoint

Create `.github/workflows/pull-request-ci.yml`.

From the same terminal, create the pull request workflow file:

```bash
touch .github/workflows/pull-request-ci.yml
```

Rules:

1. trigger on pull requests targeting `main`
2. keep it thin: trigger, concurrency, top-level permissions, and a single call into `__shared-ci.yml`
3. call `__shared-ci.yml`
4. define `concurrency`
5. start from explicit top-level `permissions: {}`
6. grant permissions per job only

If this file starts growing many build or test jobs, it is no longer thin enough. Move that logic back into `__shared-ci.yml`.

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/github-actions/>

## Step 4. Add the mainline entrypoint

Create `.github/workflows/main-ci.yml`.

From the same terminal, create the mainline workflow file:

```bash
touch .github/workflows/main-ci.yml
```

Rules:

1. trigger on pushes to `main`
2. keep it thin: trigger, concurrency if needed, scoped permissions, and a call into `__shared-ci.yml`
3. prune stale preview and runtime image tags
4. call `__shared-ci.yml`
5. regenerate Helm docs after CI succeeds
6. keep permissions explicit and scoped

This file should read like an entrypoint plus a small amount of `main`-specific behavior. It should not become a second copy of the shared workflow.

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/github-actions/>

## Step 5. Validate CI behavior

Open a pull request and inspect the workflow graph.
You should be able to explain which file owns each responsibility before comparing with the snapshot.
When you inspect the graph, check both the order of the stages and the dependency between them: later stages should wait for earlier ones.

Expected pull request behavior:

1. `pull-request-ci.yml` acts only as a thin entrypoint and delegates the real work to `__shared-ci.yml`
2. `build-ci` runs first and prepares the CI images used by the checks
3. `continuous-integration` runs next as a matrix with exactly three entries: `backend`, `frontend`, and `live-data-generator`
4. the lint, typecheck, and test checks happen inside that CI matrix, inside the matching CI image for each application; there is no separate linter job in this workshop
5. `build` runs only after every matrix check passes and prepares the deployable runtime images
6. `tests-charts` runs last and validates the Helm chart with those already-built runtime images

Expected `main` behavior after merge:

1. stale image tags are pruned
2. the same CI contract runs again
3. Helm docs are regenerated

Expected core file set in your repository after this step:

1. `.github/workflows/__shared-ci.yml`
2. `.github/workflows/pull-request-ci.yml`
3. `.github/workflows/main-ci.yml`

If the graph order is wrong, fix the job dependencies in `__shared-ci.yml`. Do not work around the problem by moving logic into the wrapper workflows.

When this step is done, open a terminal in the application repository root and commit then push your workflow changes:

```bash
git add .github/workflows
git commit -m "feat: add CI workflows"
git push
```

Read:

- <https://docs.hoverkraft.cloud/docs/methodology/best-practices/ci-cd/github-actions/>

## Step 6. Reach parity with the snapshot

If you want to get close to [steps/06-add-ci](steps/06-add-ci), add the repo-hygiene workflows present in the snapshot:

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
5. the core workflow files in your repository are `__shared-ci.yml`, `pull-request-ci.yml`, and `main-ci.yml`
6. your latest CI changes are committed and pushed
7. your result is close to [steps/06-add-ci](steps/06-add-ci)

## If you get stuck

1. compare one workflow file at a time with [steps/06-add-ci](steps/06-add-ci)
2. do not duplicate logic between PR and `main`
3. if you are changing application code, you are probably solving the wrong problem
