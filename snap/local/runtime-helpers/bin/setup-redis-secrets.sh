#!/bin/bash

# This script is called by connect-plug-edgex-secretstore-token hook
# before or after security-secretstore-setup. For details, refer to the
# respective hook script.

# The caller is the connect-plug-edgex-secretstore-token hook.
# It is only for logging purposes
caller=${1:-""}
logger "edgex-ekuiper:setup-redis-secrets: started by $caller"

VAULT_TOKEN_FILE=$SNAP_DATA/edgex-ekuiper/secrets-token.json
REDIS_TOKEN_FILE=$SNAP_DATA/edgex-ekuiper/redis.yaml
SOURCE_FILE=$SNAP_DATA/etc/sources/edgex.yaml 
CONNECTIONS_FILE=$SNAP_DATA/etc/connections/connection.yaml

# use Vault token query Redis token, access edgexfoundry secure Message Bus
i=0
while true; do
	# max 60s retry for security on mode, otherwise config files for security off mode 
	((i=i+1))
	if [ -f "$VAULT_TOKEN_FILE" ] ; then
	# get Vault token and create redis.yaml
	logger "edgex-ekuiper:setup-redis-secrets: using Vault token to query Redis token"
	TOKEN=$(yq "$VAULT_TOKEN_FILE" | yq ' .auth.client_token')
	touch "$REDIS_TOKEN_FILE"

	# check if curl work
	CURL_HTTP_CODE=$(curl -o /dev/null --write-out "%{http_code}" -s --show-error -H "X-Vault-Token: $TOKEN" -X GET http://localhost:8200/v1/secret/edgex/edgex-ekuiper/redisdb)

	# check if YQ work
	YQ_OUT=$(curl -s --show-error -H "X-Vault-Token: $TOKEN" -X GET http://localhost:8200/v1/secret/edgex/edgex-ekuiper/redisdb | yq '.data.password')
	YQ_EXIT_CODE=$?

	# check if CURL or YQ return no-zero code
		if [ $CURL_HTTP_CODE != 200 ] || [ $YQ_EXIT_CODE -ne 0 ] ; then
			logger "edgex-ekuiper:setup-redis-secrets: could not use Vault token to query Redis credentials"
			exit 1
		else
			# curl and jq work great, put Redis token into redis.yaml
			logger "edgex-ekuiper:setup-redis-secrets: sending Redis token to $REDIS_TOKEN_FILE"
			echo $YQ_OUT > "$REDIS_TOKEN_FILE"
			logger "edgex-ekuiper:setup-redis-secrets: sent Redis token to $REDIS_TOKEN_FILE"
			REDIS_PASSWORD=$(yq "$REDIS_TOKEN_FILE")

			# pass generated Redis credentials to configuration files
			logger "edgex-ekuiper:setup-redis-secrets: passing Redis token to $SOURCE_FILE"
			yq -i '.default += {"optional":{"Username":"Redis"}+{"Password":"'$REDIS_PASSWORD'"}}' "$SOURCE_FILE"

			logger "edgex-ekuiper:setup-redis-secrets: passing Redis token to $CONNECTIONS_FILE"
			yq -i '.edgex.redisMsgBus += {"optional":{"Username":"Redis"}+{"Password":"'$REDIS_PASSWORD'"}}' "$CONNECTIONS_FILE"
			
			logger "edgex-ekuiper:setup-redis-secrets: start edgex-ekuiper with edgexfoundry Vault token"
			break 2
		fi
	else
		logger "edgex-ekuiper:setup-redis-secrets: could not find Vault token to query Redis credentials, Vault token wasn't available, retrying $i/60"
		sleep 1
	fi
	if [ "$i" -ge 60 ]; then
		logger "edgex-ekuiper:setup-redis-secrets: start edgex-ekuiper without edgexfoundry Vault token as it is not available"
		break 2
	fi
done

exec "$@"

