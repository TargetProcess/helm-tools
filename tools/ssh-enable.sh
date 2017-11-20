#!/bin/sh

sshPrivateKey=$1
mkdir -p ~/.ssh
chmod -R 400 ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts
echo "$sshPrivateKey" > ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa
