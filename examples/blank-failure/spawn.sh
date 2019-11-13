#! /usr/bin/env bash

# This script can be used to create the blank-failure.git example repository.
# Since there is no commit in this repository, it creates a build failure.

set -e

export GIT_DIR="/blank/blank-failure.git"
export GIT_AUTHOR_DATE="1970-01-01T00:00:00"
export GIT_COMMITTER_DATE="1970-01-01T00:00:00"
export TZ="UTC"

git init --bare $GIT_DIR
