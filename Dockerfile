FROM node:8-alpine

RUN apk update && apk add ca-certificates && update-ca-certificates && apk add openssl && apk add bash

#  Installing git
RUN apk update && apk upgrade && apk add --no-cache git openssh

#  Installing helm
WORKDIR /tools/helm

RUN wget http://storage.googleapis.com/kubernetes-helm/helm-v2.6.2-linux-amd64.tar.gz \
    && tar -xzf helm-v2.6.2-linux-amd64.tar.gz linux-amd64/helm \
    && rm helm-v2.6.2-linux-amd64.tar.gz \
    && mv ./linux-amd64/helm ./ && rm -R ./linux-amd64 

ENV PATH /tools/helm:$PATH
# install yaml editor which preserve comments
RUN npm install -g yawn-yaml-cli

WORKDIR /tools

ADD *.sh ./
RUN chmod 755 *.sh
