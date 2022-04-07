#!/bin/bash -ex

EDGEX_SECURITY=$(snapctl get edgex-security)

if [ -n "$EDGEX_SECURITY" ]; then
  export EDGEX_SECURITY
fi

exec "$@"