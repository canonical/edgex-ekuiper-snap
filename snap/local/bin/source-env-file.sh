#!/bin/bash -ex

SERVICE="kuiperd"
ENV_FILE="$SNAP_DATA/config/$SERVICE/res/overrides.env"
TAG="$SNAP_INSTANCE_NAME."$(basename "$0")

if [ -f "$ENV_FILE" ]; then
    logger --tag=$TAG "Sourcing $ENV_FILE"
    set -o allexport
    source "$ENV_FILE" set
    set +o allexport
fi

exec "$@"
