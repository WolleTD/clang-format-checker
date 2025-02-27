#!/bin/bash
set -eu

if [ $# -ne 1 ]; then
    echo "Usage: $0 <release>" >&2
    exit 1
fi

gh_release="$1"
gh_repo="muttleyxd/clang-tools-static-binaries"
gh_url="https://github.com/${gh_repo}/releases/download/${gh_release}"

versions=( 3.9 4 5 6 7 8 9 10 11 12 12.0.1 13 14 15 16 17 18 19 )

for version in ${versions[@]}; do
    curl -sfL ${gh_url}/clang-format-${version}_linux-amd64.sha512sum
done
