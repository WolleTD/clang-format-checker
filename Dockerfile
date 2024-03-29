FROM alpine:latest

RUN apk --no-cache add git python3 patch setpriv

ARG GH_REPO="muttleyxd/clang-tools-static-binaries"
ARG GH_RELEASE="master-8f72ab3c"
ENV GH_URL="https://github.com/${GH_REPO}/releases/download/${GH_RELEASE}"
ENV CLANG_LATEST=17

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
    ${GH_URL}/clang-format-12.0.1_linux-amd64   \
    ${GH_URL}/clang-format-13_linux-amd64   \
    ${GH_URL}/clang-format-14_linux-amd64   \
    ${GH_URL}/clang-format-15_linux-amd64   \
    ${GH_URL}/clang-format-16_linux-amd64   \
    ${GH_URL}/clang-format-17_linux-amd64   \
    entrypoint.sh                           \
    check-format.sh                         \
    set-clang-version                       \
    clang-format_linux.sha512sums           \
    git-clang-format-${CLANG_LATEST}        \
    0001-remove-json-support.patch          \
    0001-remove-json-csharp-support.patch   \
    /usr/local/bin/

RUN cd /usr/local/bin && \
    patch -o git-clang-format-12 git-clang-format-${CLANG_LATEST} <0001-remove-json-support.patch && \
    patch -o git-clang-format-8 git-clang-format-${CLANG_LATEST} <0001-remove-json-csharp-support.patch && \
    chmod +rx git-clang-format-12 git-clang-format-8

RUN cd /usr/local/bin && sha512sum -c clang-format_linux.sha512sums && \
    chmod +x /usr/local/bin/clang-format-* && set-clang-version ${CLANG_LATEST} && \
    chmod go+w /usr/local/bin

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
