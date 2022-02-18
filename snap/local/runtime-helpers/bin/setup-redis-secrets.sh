#!/bin/sh

VAULT_TOKEN_FILE=$SNAP_DATA/edgex-ekuiper/secrets-token.json
REDIS_TOKEN_FILE=$SNAP_DATA/edgex-ekuiper/redis.yaml

if [ -f "$VAULT_TOKEN_FILE" ] ; then
	TOKEN=$(sudo cat $VAULT_TOKEN_FILE | jq -r '.auth.client_token')
	if [ ! -f "$SREDIS_TOKEN_FILE" ] ; then 
		touch $REDIS_TOKEN_FILE
	fi
	curl -s -H "X-Vault-Token: $TOKEN" http://localhost:8200/v1/secret/edgex/edgex-ekuiper/redisdb | jq -r '.data' >  $REDIS_TOKEN_FILE
fi
