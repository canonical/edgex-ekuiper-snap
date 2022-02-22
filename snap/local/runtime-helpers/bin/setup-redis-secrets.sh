#!/bin/sh

VAULT_TOKEN_FILE=$SNAP_DATA/edgex-ekuiper/secrets-token.json
REDIS_TOKEN_FILE=$SNAP_DATA/edgex-ekuiper/redis.yaml
SOURCE_FILE=$SNAP_DATA/etc/sources/edgex.yaml 
CONNECTIONS_FILE=$SNAP_DATA/etc/connections/connection.yaml

echo "Running setup script"
while true; do
	if [ -f "$VAULT_TOKEN_FILE" ] ; then
		TOKEN=$(cat $VAULT_TOKEN_FILE | jq -r '.auth.client_token')
		curl -s -H "X-Vault-Token: $TOKEN" http://localhost:8200/v1/secret/edgex/edgex-ekuiper/redisdb | tac | tac | jq -r '.data.password' >  $REDIS_TOKEN_FILE
		EXIT_CODE=$?
		if [ $EXIT_CODE -ne 0 ] ; then
			echo "Can't query Redis credentials with exit code: $EXIT_CODE"
			>&2 echo $EXIT_CODE
			exit 1
		fi
	else
		echo "Can't find secrets-token.json file, retrying."
		sleep 2
	fi
done

exec "$@"

