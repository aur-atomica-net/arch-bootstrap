#!/bin/bash
set -x # Echo?
set -e # Errors?
set -o pipefail

IMAGE_NAME="atomica/arch-bootstrap"
MIRROR="http://mirrors.kernel.org/archlinux"
VERSION=$(curl ${MIRROR}/iso/latest/ | grep -Poh '(?<=archlinux-bootstrap-)\d*\.\d*\.\d*(?=\-x86_64)' | head -n 1)

if [[ ! -f "archlinux-bootstrap-${VERSION}-x86_64.tar.gz" ]]; then
    curl -O -L "${MIRROR}/iso/${VERSION}/archlinux-bootstrap-${VERSION}-x86_64.tar.gz"
fi
if [[ ! -f "archlinux-bootstrap-${VERSION}-x86_64.tar.gz.sig" ]]; then
    curl -O -L "${MIRROR}/iso/${VERSION}/archlinux-bootstrap-${VERSION}-x86_64.tar.gz.sig"
fi

gpg --keyserver-options auto-key-retrieve --auto-key-locate pka --verify "archlinux-bootstrap-${VERSION}-x86_64.tar.gz.sig" "archlinux-bootstrap-${VERSION}-x86_64.tar.gz"

docker run --rm -v $(pwd):/arch-bootstrap -v /var/run/docker.sock:/var/run/docker.sock --env http_proxy=${http_proxy} --env https_proxy=${https_proxy} ubuntu:latest /bin/bash /arch-bootstrap/build-image.sh $IMAGE_NAME $VERSION

# Push to registry if configured
if [ ! -z "${DOCKER_REGISTRY}" ]; then
    docker login --username=${DOCKER_USER} --password=${DOCKER_PASS} --email=${DOCKER_EMAIL} ${DOCKER_REGISTRY}
    docker tag "${IMAGE_NAME}:latest" "${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
    docker push "${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
fi
