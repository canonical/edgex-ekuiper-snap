#!/bin/sh

VAULT_TOKEN_FILE=$SNAP_DATA/edgex-ekuiper/secrets-token.json
REDIS_TOKEN_FILE=$SNAP_DATA/edgex-ekuiper/redis.yaml
SOURCE_FILE=$SNAP_DATA/etc/sources/edgex.yaml 
CONNECTIONS_FILE=$SNAP_DATA/etc/connections/connection.yaml

if [ -f "$VAULT_TOKEN_FILE" ] ; then
	TOKEN=$(cat $VAULT_TOKEN_FILE | jq -r '.auth.client_token')
	curl -s -H "X-Vault-Token: $TOKEN" http://localhost:8200/v1/secret/edgex/edgex-ekuiper/redisdb | tac | tac | jq -r '.data.password' >  $REDIS_TOKEN_FILE
fi

REDIS_PASSWORD=$(cat REDIS_TOKEN_FILE)

# modify source/edgex.yaml
yq -i '
... comments="" |
.default.port=6379 |
.default.topic="rules-events" |
.mqtt_conf.server="localhost" |
del(.default.messageType) |
del(.zmq_conf) |
del(.share_conf) |
del(.application_conf.type) |
del(.application_conf.messageType) |
.optional += {"optional":{"Username":"Redis"}
+{"Password":'"$REDIS_PASSWORD"'}}
+{"connectionSelector":"edgex.redisMsgBus"}
' $SOURCE_FILE

# modify connections/connection.yaml
yq -i '
del(.mqtt) |
del(.edgex.mqttMsgBus) |
del(.edgex.zeroMsgBus) |
.edgex.redisMsgBus.server="localhost" |
... comments="" |
.edgex.redisMsgBus += {"optional":{"Username":"Redis"}+{"Password":'"$REDIS_PASSWORD"'}}
' connections-yaml-yq.yaml

exec "$@"

