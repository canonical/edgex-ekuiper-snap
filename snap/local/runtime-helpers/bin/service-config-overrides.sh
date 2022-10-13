#!/bin/bash -e

source=$(snapctl get source)

if [ "$source" == "app-service-confirguable" ]; then
  export EDGEX__DEFAULT__TOPIC="rules-events"
  export EDGEX__DEFAULT__MESSAGETYPE="event"
fi

exec "$@"

