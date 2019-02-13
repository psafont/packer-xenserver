FROM golang:1.11.5

RUN go get -v github.com/hashicorp/packer
WORKDIR /go/src/github.com/hashicorp/packer
RUN env GO111MODULE=on CGO_ENABLED=0 go build -o bin/packer .

RUN go get -v github.com/mitchellh/gox
RUN go get -v github.com/mitchellh/go-vnc

WORKDIR /go/src/github.com/xenserver/
RUN git clone https://github.com/psafont/packer-builder-xenserver.git --branch "static-bin"

WORKDIR /go/src/github.com/xenserver/packer-builder-xenserver
RUN CGO_ENABLED=0 ./build.sh

FROM alpine:latest

RUN apk --update add jq curl openssl bash

WORKDIR /
COPY jenkins/*.sh jenkins/
COPY internal/ internal/
COPY scripts/ scripts/

COPY --from=0 /go/src/github.com/hashicorp/packer/bin/* /bin/
COPY --from=0 /go/src/github.com/xenserver/packer-builder-xenserver/bin/* /bin/
ENTRYPOINT ["/bin/bash", "-c"]
