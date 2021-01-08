#!/bin/bash

set -e

REVISION=$(git show-ref origin/master | cut -f 1 -d ' ')
TAGGED_IMAGE=librariesio/dispatch:${REVISION}

kubectl set image deployment/dispatch-service dispatch-container=${TAGGED_IMAGE}
