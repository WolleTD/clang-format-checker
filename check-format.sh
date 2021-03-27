#!/bin/sh

FAILED=0

# Make sure target branch exists
argrev=${1}; shift
git fetch --depth=${FETCH_DEPTH:-50} origin ${argrev}
REV=`git rev-parse --verify origin/${argrev} 2>/dev/null`
[ -n "$REV" ] || REV=`git rev-parse --verify ${argrev} 2>/dev/null`
if [ -z "${REV}" ]; then
    echo "Can't find merge target!" >&2
    exit 1
fi

for c in `git rev-list --reverse HEAD ^${REV}`; do
echo -n "${c}...";
CF_OUTPUT="`git -c color.ui=always clang-format --diff "${c}^" "${c}" -- "$@"`";
if [ -z "${CF_OUTPUT}" ] || [ "${CF_OUTPUT}" == "no modified files to format" ]; then
    echo -e "\e[32mPASSED\e[0m";
else
    echo -e "\e[31;1mFAILED\e[0m"; FAILED=1;
    COMMIT_MSG=`git log -1 --oneline --no-decorate "${c}"`;
    echo "Commit ${COMMIT_MSG} introduces invalid format:";
    echo "${CF_OUTPUT}"
fi;
done
exit $FAILED
