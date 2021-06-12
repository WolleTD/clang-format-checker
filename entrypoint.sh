#!/bin/sh -e

# GitLab CI doesn't allow us to run containers with arbitrary args
# and executes a shell instead. I'd wish for just a `cd $GITLAB_PROJECT_DIR` here.
if [ -n "$GITLAB_CI" ]; then
    "$@"
    exit $?
fi

# When source-ref is provided to this action, it will attempt to initialize
# the working repository itself, thus not requiring something like actions/checkout
if ! git status 2>/dev/null; then
    if [ -z "$SOURCE_REF" ]; then
        echo "Must provide source-ref without pre-fetched repository"
        exit 1
    fi
    echo "Initializing repository..."
    git init -q "$PWD"
    git remote add origin "https://github.com/$GITHUB_REPOSITORY"
    git fetch origin --depth=$FETCH_DEPTH $SOURCE_REF
    git checkout -q $SOURCE_REF 2>/dev/null || \
        git fetch origin --depth=$FETCH_DEPTH refs/tags/$SOURCE_REF:refs/tags/$SOURCE_REF
    git checkout -q $SOURCE_REF
fi

[ -z "$CLANG_VERSION" ] || set-clang-version "$CLANG_VERSION"
check-format.sh "$@"
