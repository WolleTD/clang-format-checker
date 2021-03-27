FROM alpine:latest

RUN apk update && apk add python3 git clang

ADD check-format.sh /usr/local/bin
ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
