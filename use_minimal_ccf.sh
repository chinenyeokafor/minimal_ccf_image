#!/bin/bash

set -eu

PLATFORM=virtual
ccf_target=ccf_runtime

docker build \
    -t ${ccf_target} \
    --no-cache \
    --build-arg PLATFORM=$PLATFORM \
    -f ./${ccf_target}/Dockerfile \
    .

# Using ccf_runtime image to the sample app build to use as final image
my_app_target=my_app
CCF_VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/microsoft/CCF/releases/latest | sed 's/^.*ccf-//')
docker build \
    -t ${my_app_target} \
    --no-cache \
    --build-arg PLATFORM=$PLATFORM \
    --build-arg CCF_VERSION=$CCF_VERSION \
    --build-arg CCF_RUNTIME_IMAGE=${ccf_target} \
    -f ./${my_app_target}/Dockerfile \
    .

# Run the sample app in a container
docker run \
    --name ccf \
    --rm -v $(pwd)/app:/app \
    -p 8080:8080 \
    ${my_app_target} cchost --config /app/cchost_config_${PLATFORM}_js.json &

sleep 3 && docker rm -f ccf
