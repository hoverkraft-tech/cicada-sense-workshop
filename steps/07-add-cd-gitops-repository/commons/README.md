# Common shared resources

This folder contains manifests and shared resources that are not tied to a single environment.

Use this folder for components that must be deployed once and then reused by `dev`, `uat`, and `production`, such as namespaces, shared secrets references, cluster-wide policies, or common infrastructure building blocks.

Keep environment-specific overrides out of this folder. Those belong in the corresponding environment directories.
