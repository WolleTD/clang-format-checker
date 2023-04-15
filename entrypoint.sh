#!/bin/sh -e

# Re-execute as the user owning the .git directory or the working directory,
# if the former isn't present.
if [ $(id -u) -eq 0 ] && [ ! "$__ENTRYPOINT_REINVOKED__" ]; then
    [ -d .git ] && dir=.git || dir=.
    read uid gid < <(stat -c '%u %g' $dir)
    echo "Reinvoking as uid $uid gid $gid"
    export __ENTRYPOINT_REINVOKED__=1
    exec setpriv --reuid $uid --regid $gid --clear-groups "$0" "$@"
fi

# GitLab CI doesn't allow us to run containers with arbitrary args
# and executes a shell instead. I'd wish for just a `cd $GITLAB_PROJECT_DIR` here.
if [ -n "$GITLAB_CI" ]; then
    exec "$@"
fi

die() { echo "$@" >&2; exit 1; }

target="$1"; shift || die "error: missing target ref"
if [ -z "$1" ] || [ -e "$1" ]; then
    ref=HEAD
else
    ref="$1"; shift
fi

# When source-ref is provided to this action, it will attempt to initialize
# the working repository itself, thus not requiring something like actions/checkout
if ! git status >/dev/null 2>&1; then
    [ "$CI" ] || die "Not a git repository!"
    [ "$ref" = "HEAD" ] && ref=$GITHUB_REF_NAME
    echo "Initializing repository..."
    git init -q "$PWD"
    git remote add origin "https://github.com/$GITHUB_REPOSITORY"
fi

if [ "$CI" ]; then
    if [ "$ref" != "HEAD" ]; then
        git rev-parse -q --no-revs --verify "origin/$ref" || \
            git rev-parse -q --no-revs --verify "$ref" || \
            git fetch origin --depth=1 "$ref"
        git rev-parse -q --no-revs --verify "origin/$ref" || \
            git rev-parse -q --no-revs --verify "$ref" || \
            git fetch origin --depth=1 tag "$ref"
    fi
    # Ensure that the source revision has some history (actions/checkout also uses depth=1)
    ref=$(git rev-parse -q --verify "origin/$ref" || git rev-parse -q --verify "$ref")
    git fetch -q "--depth=$FETCH_DEPTH" origin "+${ref}"
fi

[ -z "$CLANG_VERSION" ] || set-clang-version "$CLANG_VERSION"
check-format.sh "$target" "$ref" "$@"
