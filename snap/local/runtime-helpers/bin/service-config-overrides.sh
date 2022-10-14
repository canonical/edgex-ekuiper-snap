#!/bin/bash -e

source=$(snapctl get source)

if [ "$source" == "app-service-configurable" ]; then
  export EDGEX__DEFAULT__TOPIC="rules-events"
  export EDGEX__DEFAULT__MESSAGETYPE="event"
fi

exec "$@"

