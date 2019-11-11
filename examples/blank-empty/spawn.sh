#! /usr/bin/env bash

# This script can be used to create the blank-empty.git example repository.

set -e

export GIT_DIR="/blank/blank-empty.git"
export GIT_AUTHOR_DATE="1970-01-01T00:00:00"
export GIT_COMMITTER_DATE="1970-01-01T00:00:00"
export TZ="UTC"

git init --bare $GIT_DIR

export GIT_WORK_TREE="./"
git commit --allow-empty -m'Initial commit.'
