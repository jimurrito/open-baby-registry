#!/bin/bash
# 

REPO="obr"
RUN_ARGS="-v ./db:/db -p 4000:4000 -p 4400:4400"
docker run -it --rm $RUN_ARGS jimurrito/$REPO:test