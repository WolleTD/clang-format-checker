#!/bin/sh

# GitLab CI doesn't allow us to run containers with arbitrary args
# and executes a shell instead. I'd wish for just a `cd $GITLAB_PROJECT_DIR` here.
if [ -n "$GITLAB_CI" ]; then
    "$@"
    exit $?
fi

# When source-ref is provided to this action, it will attempt to initialize
# the working repository itself, thus not requiring something like actions/checkout
if [ -n "$SOURCE_REF" ]; then
    if git status 2>/dev/null; then
        echo "Error: Git repository already exists!" >&2
        exit 1
    fi
    echo "Initializing repository..."
    git init -q "$PWD"
    git remote add origin "https://github.com/$GITHUB_REPOSITORY"
    git fetch origin --depth=$FETCH_DEPTH $SOURCE_REF
    git checkout -q $SOURCE_REF
fi

check-format.sh "$@"
