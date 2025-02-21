#!/bin/bash
IMAGE="$1"

set -e

export DOCKER_BUILDKIT=1
echo "(*) Installing @devcontainer/cli"
npm install -g @devcontainers/cli

echo "(*) Building image - ${IMAGE}"
id_label="test-container=${IMAGE}"
id_image="universal-test-image"
#devcontainer up --id-label ${id_label} --workspace-folder "src/${IMAGE}/"
if [ $IMAGE == "universal" ]; then
    devcontainer build --image-name ${id_image} --workspace-folder "src/${IMAGE}/"
    
    devcontainer up --id-label ${id_label} --workspace-folder "src/${IMAGE}/"
else
    devcontainer up --id-label ${id_label} --workspace-folder "src/${IMAGE}/"
fi
