FROM alpine:latest

RUN apk --no-cache add git python3 && ln -s python3 /usr/bin/python

ARG GH_REPO="muttleyxd/clang-tools-static-binaries"
ARG GH_RELEASE="master-a37b22cd"
ENV GH_URL="https://github.com/${GH_REPO}/releases/download/${GH_RELEASE}"

ADD ${GH_URL}/clang-format-3.9_linux-amd64  \
    ${GH_URL}/clang-format-4_linux-amd64    \
    ${GH_URL}/clang-format-5_linux-amd64    \
    ${GH_URL}/clang-format-6_linux-amd64    \
    ${GH_URL}/clang-format-7_linux-amd64    \
    ${GH_URL}/clang-format-8_linux-amd64    \
    ${GH_URL}/clang-format-9_linux-amd64    \
    ${GH_URL}/clang-format-10_linux-amd64   \
    ${GH_URL}/clang-format-11_linux-amd64   \
    ${GH_URL}/clang-format-12_linux-amd64   \
    entrypoint.sh                           \
    check-format.sh                         \
    set-clang-version                       \
    clang-format_linux.sha512sums           \
    /usr/local/bin/
ADD git-clang-format-12 /usr/local/bin/git-clang-format

RUN cd /usr/local/bin && sha512sum -c clang-format_linux.sha512sums && \
    chmod +x /usr/local/bin/clang-format-* && set-clang-version 12

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
