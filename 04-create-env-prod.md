# Production cluster

## Context

It's now time to create our **PRODUCTION** cluster.
The one that will pay your salary !
The one that will wake you up because of on-call shedules !

Wait ... In platform engineering vision, you will discover that this is not different of creating the dev cluster...

## Customize your infrastructure repo

Follow these instructions to set up the prod env:

- Open the `landing-zones/prod` folder
- Locate `env.yaml`
- Customize it by replacing `vcluster.loadBalancerIp` by the provided value in the spreadsheet.
  Beware that in case of an overlap, both teams will not be able to provision their cluster.

## Spawn the environment

1. Open a terminal in `landing-zones/prod`
2. Start the provisioning process.

- Run `mise trust`.
- Run `mise install`.
- Run `terragrunt init --all`.
- Run `terragrunt apply --all`.
- Answer `yes` when Terragrunt shows the plan and asks for confirmation.

1. Wait for the cluster request to complete.

- You should see a `wait-for-k8s` step with a countdown up to 300 seconds.
- Then wait for the batch process to satisfy the request.
- When everything succeeds, Terragrunt should finish and give you back your prompt.

If the prompt returns with an error, stop there and fix that problem before moving on to validation.

## Validation

Validate in this order:

1. run `kubectl config get-contexts` and confirm that a context named `prod` exists
2. run `kubectl get nodes` and confirm that Kubernetes returns worker nodes

If step 1 fails, make sure the kubeconfig was written correctly.

### Commititng the changes

When all steps are done, open a terminal in the `infrastructure` repository root and commit then push your changes:

```bash
git add .
git commit -m "feat: configure prod environment"
git push
```

## Exit criteria

At the end of this step, you should have a reachable `prod` cluster,
a working `prod` kubeconfig contextL.
