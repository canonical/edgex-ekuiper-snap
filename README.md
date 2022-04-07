# EdgeX eKuiper Snap

eKuiper is a lightweight IoT edge analytics software.

This is a snap packaging of eKuiper tailored to the EdgeX Foundry snap,
available at: https://snapcraft.io/edgexfoundry

The snap is designed to work with EdgeX and is not supported 
for standalone use.

The snap is **NOT SUPPORTED** by the eKuiper community.
For any EdgeX-related issues when using this snap, please refer to:
https://github.com/canonical/edgex-ekuiper-snap

eKuiper source code: https://github.com/lf-edge/ekuiper

eKuiper is a trademark of LF Projects: https://lfprojects.org

## Snap Installation
[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-white.svg)](https://snapcraft.io/edgex-ekuiper)

### Install and configure dependencies
EdgeX ekuiper depends on several other edgexfoundry services.

Please refer to [edgexfoundry Snap](https://github.com/edgexfoundry/edgex-go/blob/main/snap/README.md) for installation of the snapped version, 
and use `--channel=latest/edge`.

Install and set profile for the following edgex-app-service-configurable for ekuiper, to use [filtering functions](https://docs.edgexfoundry.org/2.2/microservices/application/AppServiceConfigurable):
```bash
sudo snap install edgex-app-service-configurable
sudo snap set edgex-app-service-configurable profile=rules-engine
sudo snap start edgex-app-service-configurable
```

After these steps, edgex-ekuiper, edgex-app-service-configurable and edgexfoundry services will be running as follows:
```bash
$ sudo snap services edgex-ekuiper edgex-app-service-configurable edgexfoundry
Service                                                  Startup   Current   Notes
edgex-app-service-configurable.app-service-configurable  disabled  active    -
edgex-ekuiper.kuiper                                     enabled   active    -
edgexfoundry.app-service-configurable                    disabled  inactive  -
edgexfoundry.consul                                      enabled   active    -
edgexfoundry.core-command                                enabled   active    -
edgexfoundry.core-data                                   enabled   active    -
edgexfoundry.core-metadata                               enabled   active    -
edgexfoundry.device-virtual                              disabled  inactive  -
edgexfoundry.kong-daemon                                 enabled   active    -
edgexfoundry.kuiper                                      disabled  inactive  -
edgexfoundry.postgres                                    enabled   active    -
edgexfoundry.redis                                       enabled   active    -
edgexfoundry.security-bootstrapper-redis                 enabled   inactive  -
edgexfoundry.security-consul-bootstrapper                enabled   inactive  -
edgexfoundry.security-proxy-setup                        enabled   inactive  -
edgexfoundry.security-secretstore-setup                  enabled   inactive  -
edgexfoundry.support-notifications                       disabled  inactive  -
edgexfoundry.support-scheduler                           disabled  inactive  -
edgexfoundry.sys-mgmt-agent                              disabled  inactive  -
edgexfoundry.vault                                       enabled   active    -
```
## Snap Configuration
The service starts by default, and can be restarted as follows. 
It will pick up any change made to config files:
```bash
sudo snap restart edgex-ekuiper.kuiper
```
The service can be stopped as follows. The `--disable` option
ensures that as well as stopping the service now, 
it will not be automatically started on boot:
```bash
sudo snap stop --disable edgex-ekuiper.kuiper
```
The service can be started as follows. 
The `--enable` option ensures that as well as starting the service now, 
it will be automatically started on boot:
```bash
sudo snap start --enable edgex-ekuiper.kuiper
```
### Configuration files
The basic configuration file for ekuiper is at `/var/snap/edgex-ekuiper/current/etc/kuiper.yaml`. 
For more details, please refer to [lf-edge/ekuiper docs](https://github.com/lf-edge/ekuiper/blob/master/docs/en_US/operation/config/configuration_file.md).

The `/var/snap/edgex-ekuiper/current/etc` directory contains the configuration files of eKuiper. 
These include configurations such as for sources, sinks, and connections.
### Connect to edgexfoundry secure message bus
By default, ekuiper enables its service on install. 
If there is no secret file under `/var/snap/edgex-ekuiper/current/edgex-ekuiper/secrets-token.json`, 
then it connects to EdgeX message bus without authentication. 
#### edgexfoundry security-on mode
edgexfoundry has security turned on by default.

- If edgexfoundry has been installed before ekuiper, ekuiper will get secret automatically.

- If edgexfoundry has been installed after ekuiper, the running ekuiper needs `snap restart` pick up the secret, 
to enter the edgexfoundry's security message bus:
```bash
sudo snap restart edgex-ekuiper
```
### Work without edgex-app-service-configurable filtering:
```bash
sudo snap stop edgex-app-service-configurable
```
Modify ekuiper's config files:
```bash
# Change sources' `topic` from edgex-app-service-configurable to edgexfoundry message bus:
sudo nano /var/snap/edgex-ekuiper/current/etc/sources/edgex.yaml
# change: 
topic: rules-events
# to:
topic: edgex/events/#
# Change sources' `messageType` from event (default) to request:
sudo nano /var/snap/edgex-ekuiper/current/etc/sources/edgex.yaml
# add:
default:
	messageType: request
```
Pick up any changes made to config files:
```bash
sudo snap restart edgex-ekuiper
```
### Viewing logs
To view the logs for the service in the edgex-ekuiper snap:
```
sudo snap logs -f edgex-ekuiper.kuiper
```
## Tagging
This repository is tagged after the eKuiper project with a [semver build metadata](https://semver.org/#spec-item-10) `snap` suffix.
For example, if eKuiper is tagged as `1.4.3`, this repository will be tagged as `1.4.3+snap`, `1.4.3+snap.2`, `1.4.3+snap.N`. The build version increments indicate updates to the snap packaging on top of the same eKuiper release.

The [release](https://github.com/canonical/edgex-ekuiper-snap/actions/workflows/release.yml) Github workflow can be used to manually tag and release, enforcing the above schema.
