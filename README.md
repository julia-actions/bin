# bin

Scripts used across the julia-actions organisation.

## Prerequisites
- `git`
- `jq`

## Scripts

- [`build-release`](build-release): Create a release branch, build action and create/update tags based on the version specified in `package.json`.
- [`build-test-release`](build-test-release): Create a branch `test/"$branch_name"/releases/"$version"` and build action for testing purposes, where `branch_name` is the name of your currently checked out branch and `version` is the version specified in `package.json`.
