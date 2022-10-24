# EdgeX eKuiper Snap
[![edgex-ekuiper](https://snapcraft.io/edgex-ekuiper/badge.svg)](https://snapcraft.io/edgex-ekuiper)

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

The snap is built automatically and published on the Snap Store as [edgex-ekuiper].

## Snap Installation
Please refer to the [edgex-ekuiper] snap store listing for installation and releases.

### EdgeX Integration
This snap works together with several other EdgeX services.

Please refer to [EdgeX Getting Started](https://docs.edgexfoundry.org/2.3/getting-started/Ch-GettingStartedUsers/) for setting up the platform using snaps.

#### Message Bus (Redis)
The eKuiper service connects to Redis and subscribes to events.
By default, the connection needs authentication.

#### Secret Store (Vault)
When this snap is installed together with the [edgexfoundry] snap, it will use the `edgex-secretstore-token` content interface to receive a Vault token for an addon-service named `edgex-ekuiper`. 

> **Note**  
> The [edgexfoundry] `2.2.0-dev.32` or later is configured to issue the token automatically; see [PR #3888](https://github.com/edgexfoundry/edgex-go/pull/3888). This version is currently available in `latest/beta` channel.
>
> For versions prior to this, the `edgex-ekuiper` add-on service with `redisdb` known secret token can be added by configuration. Please refer to [Configuring Add-on Services](https://docs.edgexfoundry.org/2.3/security/Ch-Configuring-Add-On-Services/) and edgexfoundry snap [readme](https://github.com/edgexfoundry/edgex-go/tree/jakarta/snap#secret-store-settings-prefix-envsecurity-secret-store) for details.

The token is expected at `/var/snap/edgex-ekuiper/current/edgex-ekuiper/secrets-token.json` and may be supplied via other means.

This snap uses the Vault token to query Redis credentials from Vault. It then injects the credentials into relevant eKuiper config files.

If the token is not available, the service will exit with error and restart automatically.

> **Option**  
> To disable the Vault token requirement and skip credentials query and config injection, set the following option:
> ```
> sudo snap set edgex-ekuiper config.edgex-security-secret-store=false
> ```
> *This option is experimental and subject to change without notice.*

#### EdgeX events source
eKuiper subscribes to all EdgeX events by default.
The default configuration expects that events are published to the EdgeX message bus under `edgex/events/#` topic.


To enable [filtering](https://docs.edgexfoundry.org/2.3/microservices/application/AppServiceConfigurable) using the [app-service-configurable] snap, 
please  refer to [Work with App Service Configurable filtering](#work-with-app-service-configurable-filtering) details below.

#### System overview
The default setup described above will prepare the system such that:
- `edgex-ekuiper` is inactive and disabled
- `edgexfoundry.kuiper` and `edgexfoundry.app-service-configurable` are inactive and disabled - these are deprecated and embedded versions of eKuiper and App Service Configurable which we do not use here.
- `edgexfoundry`'s `vault` and `redis`, along with other core services are active and enabled

Verify that by executing the following command:
```bash
$ sudo snap start edgex-ekuiper
$ sudo snap services edgex-ekuiper edgexfoundry
Service                                                  Startup   Current   Notes
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

To change the default configuration, refer below.

## Snap Configuration
The eKuiper service is started by default after installation.

Config files are loaded on startup.
To restart a running instance and load new configurations:
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
The basic server configuration file for eKuiper is at `/var/snap/edgex-ekuiper/current/etc/kuiper.yaml`.
For details, please refer to [this](https://github.com/lf-edge/ekuiper/blob/master/docs/en_US/operation/config/configuration_file.md) eKuiper document.

The `/var/snap/edgex-ekuiper/current/etc` directory contains the configuration files of eKuiper. 
These include the basic server configuration, as well as configurations such as for sources, sinks, and connections.

### Work with App Service Configurable filtering:
Instead of subscribing to all EdgeX events, eKuiper can be configured to subscribe to events filtered by EdgeX App Service Configurable.

To do so, install [edgex-app-service-configurable](https://snapcraft.io/edgex-app-service-configurable), and set its profile to `rules-engine`:
```bash
snap install edgex-app-service-configurable
snap set edgex-app-service-configurable profile=rules-engine
snap start edgex-app-service-configurable
````
Then, set eKuiper to subscribe to `app-service-configurable` by changing ekuiper's 
default topic from 'rules-event' to 'edgex/events/#', default messageType from 'event' to 'request':
```bash
snap set edgex-ekuiper config.edgex.default.topic=rules-events config.edgex.default.messagetype=event
# restart is required to load new configuration options
snap restart edgex-ekuiper
```
Unsetting the above changes will revert ekuiper to default settings (subscribe to all EdgeX events):
```bash
snap unset edgex-ekuiper config.edgex.default.topic config.edgex.default.messagetype
# restart is required to load new configuration options
snap restart edgex-ekuiper
```


### Viewing logs
For example, to print 100 lines and follow the logs:
```
snap logs -n=100 -f edgex-ekuiper
```

## Tagging
This repository is tagged after the eKuiper project with a [semver build metadata](https://semver.org/#spec-item-10) `snap` suffix.
For example, if eKuiper is tagged as `1.4.3`, this repository will be tagged as `1.4.3+snap`, `1.4.3+snap.2`, `1.4.3+snap.N`. The build version increments indicate updates to the snap packaging on top of the same eKuiper release.

The [release](https://github.com/canonical/edgex-ekuiper-snap/actions/workflows/release.yml) Github workflow can be used to manually tag and release, enforcing the above schema.


[edgex-ekuiper]: https://snapcraft.io/edgex-ekuiper
[edgexfoundry]: https://snapcraft.io/edgexfoundry
[app-service-configurable]: https://snapcraft.io/edgex-app-service-configurable
