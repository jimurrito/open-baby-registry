#!/bin/bash
#
# Docker Container build Test Script.
#
# Compiles and launches app within the local docker container.


#REPO=$(basename "$(git rev-parse --show-toplevel)")
REPO="obr"
RUN_ARGS="--hostname "obr" -v ./db:/db -p 4000:4000 -p 4400:4400"

docker build -t jimurrito/$REPO:test .
docker run -it --rm $RUN_ARGS jimurrito/$REPO:test
