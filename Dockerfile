FROM ubuntu:20.04

RUN apt-get update && apt-get install -y git clang-format # for git-clang-format

ARG GH_REPO="muttleyxd/clang-tools-static-binaries"
ARG GH_RELEASE="master-a37b22cd"

ENV GH_URL="https://github.com/${GH_REPO}/releases/download/${GH_RELEASE}"

ADD ${GH_URL}/clang-format-3.9_linux-amd64 \
    ${GH_URL}/clang-format-4_linux-amd64   \
    ${GH_URL}/clang-format-5_linux-amd64   \
    ${GH_URL}/clang-format-6_linux-amd64   \
    ${GH_URL}/clang-format-7_linux-amd64   \
    ${GH_URL}/clang-format-8_linux-amd64   \
    ${GH_URL}/clang-format-9_linux-amd64   \
    ${GH_URL}/clang-format-10_linux-amd64  \
    ${GH_URL}/clang-format-11_linux-amd64  \
    ${GH_URL}/clang-format-12_linux-amd64  \
    /usr/local/bin/

ADD check-format.sh set-clang-version /usr/local/bin/
ADD clang-format_linux.sha512sums /root/
RUN cd /usr/local/bin && sha512sum -c /root/clang-format_linux.sha512sums && set-clang-version 12

ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
