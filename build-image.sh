#!/bin/sh
set -x # Echo?
set -e # Errors?
set -o pipefail

IMAGE_NAME=$1
VERSION=$2

tar xf /arch-bootstrap/archlinux-bootstrap-${VERSION}-x86_64.tar.gz

tar --numeric-owner -C root.x86_64 -c . | docker import - "${IMAGE_NAME}:${VERSION}"
docker tag "${IMAGE_NAME}:${VERSION}" "${IMAGE_NAME}:latest"
