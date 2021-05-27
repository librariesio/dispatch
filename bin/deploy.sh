#!/bin/bash

set -e

REVISION=$(git show-ref origin/main | cut -c1-7)

echo "Verify ${REVISION} is pushed to Dockerhub before continuing!"
read -p "Do you see it at https://hub.docker.com/r/librariesio/dispatch/builds [yN]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  kubectl set image deployment/dispatch-service dispatch-container=librariesio/dispatch:latest
fi
