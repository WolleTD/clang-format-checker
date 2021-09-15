#!/bin/sh
set -e

exitCode=0
[ -z "$(echo -e)" ] || { echo "Error: needs echo with -e support" >&2; exit 1; }

# Ensure that the current HEAD has some history (by default this is not the case with actions/checkout)
head_sha=$(git rev-parse --verify HEAD)
git fetch "--depth=${FETCH_DEPTH:-50}" origin "+${head_sha}"

# Make sure target branch exists
revisionArg=${1}; shift
revision=$(git rev-parse --verify origin/${revisionArg} 2>/dev/null) || {
    git fetch --depth=${FETCH_DEPTH:-50} origin ${revisionArg}
    revision=$(git rev-parse --verify origin/${revisionArg} 2>/dev/null || \
        git rev-parse --verify ${revisionArg} 2>/dev/null) || {
            echo "Can't find merge target '${revision}'!" >&2
            return 1
        }
}

[ -n "${revision}" ] || { echo "Error: Programmer is an idiot" >&2; exit 1; }
echo "Checking $(git rev-list --count --reverse "HEAD" "^${revision}") commits since revision ${revision}"

for commit in $(git rev-list --reverse "HEAD" "^${revision}"); do
    echo -n "${commit}..."
    cfOutput="$(git -c color.ui=always clang-format --diff "${commit}^" "${commit}" -- "$@")";
    if [ -z "${cfOutput}" ] || [ "${cfOutput}" = "no modified files to format" ]; then
        echo -e "\e[32mPASSED\e[0m"
    else
        echo -e "\e[31;1mFAILED\e[0m"
        exitCode=1
        commitMessage=$(git log -1 --oneline --no-decorate "${commit}");
        echo "Commit ${commitMessage} introduces invalid format:";
        echo "${cfOutput}"
    fi
done
exit ${exitCode}
