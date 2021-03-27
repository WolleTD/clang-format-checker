FROM ubuntu:20.10

RUN apt-get update && apt-get install -y git clang-format-11
RUN ln -sf `which git-clang-format-11` /usr/bin/git-clang-format && \
    ln -sf `which clang-format-11` /usr/bin/clang-format

ADD check-format.sh /usr/local/bin
ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
