#!/bin/sh
set -e

die() { echo "$@" >&2; exit 1; }

exitCode=0

# Make sure target branch exists
target="$1"; shift

if [ "$CI" ]; then
    git rev-parse -q --no-revs --verify "origin/${target}" || \
        git rev-parse -q --no-revs --verify "${target}" || \
        git fetch origin --depth=1 "${target}"
    git rev-parse -q --no-revs --verify "origin/${target}" || \
        git rev-parse -q --no-revs --verify "${target}" || \
        git fetch origin --depth=1 tag "${target}"
    # Ensure that the target revision has some history
    target_sha=$(git rev-parse -q --verify "origin/${target}" || git rev-parse -q --verify "${target}")
    git fetch -q "--depth=${FETCH_DEPTH:-50}" origin "+${target_sha}"
else
    target_sha=$(git rev-parse -q --verify "${target}") || die "fatal: couldn't find ref ${target}"
fi

if [ -z "$1" ] || [ -e "$1" ]; then
    src=HEAD
else
    src="$1"; shift
fi

# We expect the user or CI (either GitLab or entrypoint.sh) to have taken care of source history
src_sha=$(git rev-parse -q --verify "${src}") || die "fatal: couldn't find ref ${src}"

echo "Using $(clang-format --version)"

echo "Checking $(git rev-list --count "${src_sha}" "^${target_sha}") commits since revision ${target_sha}"

for commit in $(git rev-list --reverse "${src_sha}" "^${target_sha}"); do
    printf "%s" "${commit}... "
    cfOutput="$(git -c color.ui=always clang-format --diff "${commit}^" "${commit}" -- "$@")";
    if [ "$SHOW_SKIPPED" ] && [ "${cfOutput}" = "no modified files to format" ]; then
        printf "%b\n" "\e[32mSKIPPED\e[0m"
    elif [ -z "${cfOutput}" ] || [ "${cfOutput}" = "no modified files to format" ]; then
        printf "%b\n" "\e[32mPASSED\e[0m"
    else
        printf "%b\n" "\e[31;1mFAILED\e[0m"
        exitCode=1
        commitMessage=$(git log -1 --oneline --no-decorate "${commit}");
        echo "Commit ${commitMessage} introduces invalid format:";
        echo "${cfOutput}"
    fi
done
exit ${exitCode}
