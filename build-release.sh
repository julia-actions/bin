#!/usr/bin/env bash

set -euf -o pipefail

set +u
repo="$1"
set -u

# Uncomment the following line to help when debugging
# set -x

# Make sure all dependencies exist
which curl
which git
which jq
which npm
which sed

branch_name="$(git symbolic-ref --short -q HEAD)"
_version_without_v="$(jq -r .version package.json)"
# A quick sanity check to make sure
# that _version_without_v is not
# empty.
version="v${_version_without_v:?}"

if [ -z "${repo}" ]; then
    echo "ERROR: must specify repository"
    echo "Usage: ./bin/build-release.sh orgname/reponame"
    exit 1
fi

echo "=== debug info ==="
echo "branch: ${branch_name:?}"
echo "version: ${version:?}"
echo "repo: ${repo:?}"
echo "ostype: ${OSTYPE:?}"
echo "=================="
echo ""

# Check that the version doesn't exist yet
version_exists="$(curl -s https://api.github.com/repos/"$repo"/tags -H "Accept: application/vnd.github.v3.full+json" | jq -r '.[] | select(.name == "'"$version"'") | .name')"
if [ -n "${version_exists}" ]; then # We intentionall don't do `:?` here, because we know `version_exists` might be empty
    echo "ERROR: version ${version:?} already exists"
    exit 1
fi

git checkout -b releases/"${version:?}"

npm install
npm run build
npm test
npm run pack

if [[ "${OSTYPE:?}" == "darwin"* ]]; then
    sed -i '' 's/dist/!dist/g' .gitignore
else
    sed -i 's/dist/!dist/g' .gitignore
fi
git add dist
git commit -a -m "Add production dependencies & build"

# Tags
major_minor="$(sed 's/\.[^.]*$//' <<< "$version")"
major="$(sed 's/\.[^.]*$//' <<< "$major_minor")"

# For this tag, we intentionally do NOT force tag:
git tag "${version:?}"

# For the remaining tags, we need to force tag:
git tag -f "${major_minor:?}"
git tag -f "${major:?}"
git tag -f "latest"
