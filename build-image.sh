#!/bin/bash
set -x # Echo?
set -e # Errors?
set -o pipefail

IMAGE_NAME=$1
VERSION=$2

apt-get update
apt-get install -y apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get -y install docker-engine

tar xf /arch-bootstrap/archlinux-bootstrap-${VERSION}-x86_64.tar.gz

tar --numeric-owner -C root.x86_64 -c . | docker import - "${IMAGE_NAME}:${VERSION}"
docker tag "${IMAGE_NAME}:${VERSION}" "${IMAGE_NAME}:latest"
