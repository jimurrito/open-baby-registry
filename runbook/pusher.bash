#!/bin/bash

VERSION=$1

#REPO=$(basename "$(git rev-parse --show-toplevel)")
REPO="obr"

if [[ -z $VERSION ]]; then
    echo "Please provide a version number as an argument."
    echo "Ex: bash .pusher.bash '0.1.6'"
    exit 1
fi

if [[ -z "$(docker buildx ls | grep jimurrito-builder)" ]]; then
    docker buildx create --name jimurrito-builder --driver docker-container --use --bootstrap
fi

docker buildx build --pull --push \
    --platform linux/amd64,linux/arm64 \
    -t "jimurrito/$REPO:$VERSION" \
    -t jimurrito/$REPO:latest .