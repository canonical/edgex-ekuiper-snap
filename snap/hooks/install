#!/bin/sh

# create directories in $SNAP_DATA
if [ ! -f "$SNAP_DATA/data" ]; then
    mkdir -p "$SNAP_DATA/data"
    mkdir -p "$SNAP_DATA/etc/functions"
    mkdir -p "$SNAP_DATA/etc/multilingual"
    mkdir -p "$SNAP_DATA/etc/services"
    mkdir -p "$SNAP_DATA/etc/sinks"
    mkdir -p "$SNAP_DATA/etc/sources"
    mkdir -p "$SNAP_DATA/etc/connections"

    mkdir -p "$SNAP_DATA/plugins/functions"
    mkdir -p "$SNAP_DATA/plugins/sinks"
    mkdir -p "$SNAP_DATA/plugins/sources"
    mkdir -p "$SNAP_DATA/plugins/portable"

    for cfg in client kuiper mqtt_source; do
        cp "$SNAP/etc/$cfg.yaml" "$SNAP_DATA/etc"
    done

    cp "$SNAP/etc/connections/connection.yaml" "$SNAP_DATA/etc/connections"

    # Only include the plugin metadata file for mqtt_source,
    # as EdgeX currently doesn't provide a default MQTT broker.
    # Even if it did, configuration (including security) would
    # need to be provided by configuration file (!compliant).
    cp "$SNAP/etc/mqtt_source.json" "$SNAP_DATA/etc"

    cp "$SNAP/etc/functions/"*.json "$SNAP_DATA/etc/functions"

    cp "$SNAP/etc/services/"*.proto "$SNAP_DATA/etc/services"

    for sink in file edgex influx log nop mqtt; do
        cp "$SNAP/etc/sinks/$sink.json" "$SNAP_DATA/etc/sinks"
    done

    cp "$SNAP/etc/sources/edgex.json" "$SNAP_DATA/etc/sources"
    cp "$SNAP/etc/sources/edgex.yaml" "$SNAP_DATA/etc/sources"

    cp "$SNAP/etc/multilingual/"*.ini "$SNAP_DATA/etc/multilingual"
fi
