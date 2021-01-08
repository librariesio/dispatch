#!/bin/bash

set -e

REVISION=$(git show-ref origin/main | cut -f 1 -d ' ')
TAGGED_IMAGE=gcr.io/${GOOGLE_PROJECT}/dispatch:${REVISION}
gcloud --quiet container images describe ${TAGGED_IMAGE} || { status=$?; echo "Container not finished building" >&2; exit $status; }

gcloud --quiet container images add-tag ${TAGGED_IMAGE} gcr.io/${GOOGLE_PROJECT}/dispatch:latest

kubectl set image deployment/libraries-dispatch libraries-dispatch-container=${TAGGED_IMAGE}
