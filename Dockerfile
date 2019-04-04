ARG alpine_version=edge

FROM alpine:${alpine_version} as base
RUN apk update && apk upgrade

#
# git-gau build stage
#
FROM base as gitgau-build

RUN apk add --no-cache make

RUN mkdir /src /dist

ARG gitgau_ref=master
ENV gitgau_ref ${gitgau_ref}

ADD "https://codeload.github.com/znerol/git-gau/tar.gz/${gitgau_ref}" /src/git-gau-src.tar.gz
RUN tar -o -C /src -xf /src/git-gau-src.tar.gz
RUN make -C /src/git-gau-* prefix=/dist install-bin

#
# certhub build stage
#
FROM base as certhub-build

RUN apk add --no-cache make

RUN mkdir /src /dist

ARG certhub_ref=master
ENV certhub_ref ${certhub_ref}

ADD "https://codeload.github.com/certhub/certhub/tar.gz/${certhub_ref}" /src/certhub-src.tar.gz
RUN tar -o -C /src -xf /src/certhub-src.tar.gz
RUN make -C /src/certhub-* prefix=/dist install-bin

#
# lego build stage
#
FROM base as lego-build

RUN apk add --no-cache make musl-dev git go

RUN mkdir /src /dist

ARG lego_ref=master
ENV lego_ref ${lego_ref}

ENV GOPATH /go
RUN mkdir -p /go/src/github.com/go-acme && \
    git clone --recurse https://github.com/go-acme/lego.git /go/src/github.com/go-acme/lego && \
    git -C /go/src/github.com/go-acme/lego checkout "${lego_ref}" && \
    make -C /go/src/github.com/go-acme/lego build && \
    install -m 0755 -D /go/src/github.com/go-acme/lego/dist/lego /dist/bin/lego

#
# runtime image stage
#
FROM base

RUN apk add --no-cache ca-certificates curl git openssh-client openssl tini

COPY --from=gitgau-build /dist /usr
COPY --from=certhub-build /dist /usr
COPY --from=lego-build /dist /usr

RUN addgroup -S certhub && adduser -S certhub -G certhub

USER certhub

ENTRYPOINT [ \
    "/sbin/tini", \
    "--", \
    "/usr/bin/ssh-agent", \
    "/usr/lib/git-gau/docker-entry", \
    "/usr/lib/git-gau/docker-entry.d" \
]
