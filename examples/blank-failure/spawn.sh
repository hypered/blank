#! /usr/bin/env bash

# This script can be used to create the blank-failure.git example repository.
# Since there is no commit in this repository, it creates a build failure.

set -e

HOME_DIR="/var/lib/blank"
REPO_PATH="${HOME_DIR}/repos/alice/blank-failure.git"
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

unset GIT_DIR
unset GIT_WORK_TREE
nix-prefetch-git --quiet --leave-dotGit ${REPO_PATH} > ../blank-failure.json
