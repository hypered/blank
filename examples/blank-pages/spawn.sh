#! /usr/bin/env bash

# This script can be used to create the blank-pages.git example repository.

set -e

HOME_DIR="/var/lib/blank"
REPO_PATH="${HOME_DIR}/repos/alice/blank-pages.git"
export GIT_DIR="${REPO_PATH}"

# Set a few Git environment variables to always create exactly the same
# repository.
export GIT_AUTHOR_NAME="alice"
export GIT_AUTHOR_EMAIL="alice@users.noreply.reesd.com"
export GIT_AUTHOR_DATE="1970-01-01T00:00:00"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
export TZ="UTC"

git init --bare $GIT_DIR

export GIT_WORK_TREE="./"
git commit --allow-empty -m'Initial commit.'

git add README.md
git commit -m'Add README.md file.'

git add default.nix
git commit -m'Add a default.nix file.'

unset GIT_DIR
unset GIT_WORK_TREE
nix-prefetch-git --quiet --leave-dotGit ${REPO_PATH} > ../blank-pages.json
