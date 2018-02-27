FROM golang:1.10.0-stretch

WORKDIR /go/src/terraform-diff
COPY . /go/src/terraform-diff
RUN apt-get update -qq && \
      apt-get install -y zopfli && \
      rm -rf /var/lib/apt/lists/* && \
      make init
