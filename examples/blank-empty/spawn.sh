#! /usr/bin/env bash

# This script can be used to create the blank-empty.git example repository.

set -e

export GIT_DIR="/blank/blank-empty.git"

# Set a few Git environment variables to always create exactly the same
# repository.
export GIT_AUTHOR_NAME="Alice"
export GIT_AUTHOR_EMAIL="alice@example.com"
export GIT_AUTHOR_DATE="1970-01-01T00:00:00"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
export TZ="UTC"

git init --bare $GIT_DIR

export GIT_WORK_TREE="./"
git commit --allow-empty -m'Initial commit.'
