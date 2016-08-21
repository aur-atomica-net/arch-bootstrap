#!/bin/sh
set -x # Echo?
set -e # Errors?
set -o pipefail

IMAGE_NAME="atomica/arch-bootstrap"
MIRROR="http://mirrors.kernel.org/archlinux"
VERSION=$(curl ${MIRROR}/iso/latest/ | grep -E "archlinux-bootstrap-\d{4}\.\d{2}.\d{2}-x86_64.tar.gz" | grep -Eo "\d{4}\.\d{2}.\d{2}" | head -n1)
DOCKER_VERSION=$(docker version --format '{{.Server.Version}}')

if [[ ! -f "archlinux-bootstrap-${VERSION}-x86_64.tar.gz" ]]; then
    curl -O -L "${MIRROR}/iso/${VERSION}/archlinux-bootstrap-${VERSION}-x86_64.tar.gz"
fi
if [[ ! -f "archlinux-bootstrap-${VERSION}-x86_64.tar.gz.sig" ]]; then
    curl -O -L "${MIRROR}/iso/${VERSION}/archlinux-bootstrap-${VERSION}-x86_64.tar.gz.sig"
fi

gpg --keyserver-options auto-key-retrieve --auto-key-locate keyserver --keyserver pool.sks-keyservers.net --verify "archlinux-bootstrap-${VERSION}-x86_64.tar.gz.sig" "archlinux-bootstrap-${VERSION}-x86_64.tar.gz"

docker run --rm -v $(pwd):/arch-bootstrap -v /var/run/docker.sock:/var/run/docker.sock --env http_proxy=${http_proxy} --env https_proxy=${https_proxy} docker:$DOCKER_VERSION /bin/sh /arch-bootstrap/build-image.sh $IMAGE_NAME $VERSION

# Push to registry if configured
if [ ! -z "${DOCKER_REGISTRY}" ]; then
    docker login --username=${DOCKER_USER} --password=${DOCKER_PASS} --email=${DOCKER_EMAIL} ${DOCKER_REGISTRY}
    docker tag "${IMAGE_NAME}:latest" "${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
    docker push "${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
fi
