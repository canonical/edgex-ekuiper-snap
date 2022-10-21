#!/bin/bash -e

SERVICE="kuiper"
SERVICE_ENV="$SNAP_DATA/config/$SERVICE/res/$SERVICE.env"
TAG="edgex-$SERVICE."$(basename "$0")

if [ -f "$SERVICE_ENV" ]; then
    logger --tag=$TAG "Sourcing $SERVICE_ENV"
    set -o allexport
    source "$SERVICE_ENV" set
    set +o allexport
fi

exec "$@"
