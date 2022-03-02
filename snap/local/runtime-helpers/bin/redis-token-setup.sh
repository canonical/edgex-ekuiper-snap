#!/bin/bash

logger "edgex-ekuiper:redis-token-setup: started"

VAULT_TOKEN_FILE=$SNAP_DATA/edgex-ekuiper/secrets-token.json
REDIS_TOKEN_FILE=$SNAP_DATA/edgex-ekuiper/redis.yaml
SOURCE_FILE=$SNAP_DATA/etc/sources/edgex.yaml 
CONNECTIONS_FILE=$SNAP_DATA/etc/connections/connection.yaml

YQ_EXIT_CODE()
{
	local EXIT_CODE=$1
	if [ $EXIT_CODE -ne 0 ] ; then
		logger --stderr "edgex-ekuiper:redis-token-setup: yq return no-zero exit code: $EXIT_CODE"
		exit 1
	fi
}

# use Vault token query Redis token, access edgexfoundry secure Message Bus
if [ -f "$VAULT_TOKEN_FILE" ] ; then
	# get Vault token and create redis.yaml
	logger "edgex-ekuiper:redis-token-setup: using Vault token to query Redis token"
	TOKEN=$(yq "$VAULT_TOKEN_FILE" | yq ' .auth.client_token')
	EXIT_CODE=$?
	YQ_EXIT_CODE $EXIT_CODE 

    # check if CURL works
	CURL_RES=$(curl --silent --write-out "%{http_code}" \
	--header "X-Vault-Token: $TOKEN" \
	--request GET http://localhost:8200/v1/secret/edgex/edgex-ekuiper/redisdb)

	# check CURL's exit code
	EXIT_CODE=$?
	if [ $EXIT_CODE -ne 0 ] ; then
		logger --stderr "edgex-ekuiper:redis-token-setup: curl return no-zero exit code: $EXIT_CODE, with response: $CURL_RES"
		exit 1
	fi

	# check CURL's http code
	HTTP_CODE="${CURL_RES:${#CURL_RES}-3}"
	if [ $HTTP_CODE -ne 200 ] ; then
	  logger --stderr "edgex-ekuiper:redis-token-setup: curl return error with http code: $HTTP_CODE, with response: $CURL_RES"
	  exit 1
	fi

	# get CURL's reponse
	if [ ${#CURL_RES} -eq 3 ]; then
	  BODY=""
	else
	  BODY="${CURL_RES:0:${#CURL_RES}-3}"
	fi

	# process the reponse and check if yq works
	YQ_RES=$($RES| yq '.data.password')
	EXIT_CODE=$?
	YQ_EXIT_CODE $EXIT_CODE

	# put Redis token into redis.yaml
	logger "edgex-ekuiper:redis-token-setup: sending Redis token to $REDIS_TOKEN_FILE"
	echo $YQ_OUT > "$REDIS_TOKEN_FILE"
	logger "edgex-ekuiper:redis-token-setup: sent Redis token to $REDIS_TOKEN_FILE"
	REDIS_PASSWORD=$(yq "$REDIS_TOKEN_FILE")
	EXIT_CODE=$?
	YQ_EXIT_CODE $EXIT_CODE

	# pass generated Redis credentials to configuration files
	logger "edgex-ekuiper:redis-token-setup: sending Redis token to $SOURCE_FILE"
	yq -i '.default += {"optional":{"Username":"Redis"}+{"Password":"'$REDIS_PASSWORD'"}}' "$SOURCE_FILE"
	EXIT_CODE=$?
	YQ_EXIT_CODE $EXIT_CODE
	logger "edgex-ekuiper:redis-token-setup: sending Redis token to $CONNECTIONS_FILE"
	yq -i '.edgex.redisMsgBus += {"optional":{"Username":"Redis"}+{"Password":"'$REDIS_PASSWORD'"}}' "$CONNECTIONS_FILE"
	EXIT_CODE=$?
	YQ_EXIT_CODE $EXIT_CODE

	logger "edgex-ekuiper:redis-token-setup: start edgex-ekuiper with edgexfoundry Vault token"
else
	logger "edgex-ekuiper:connect-slot-edgex-secretstore-token: start edgex-ekuiper without edgexfoundry Vault token as it is not available"
fi

exec "$@"

