# Varnish-Image

Repo-Url: [https://gitlab.com/strowi/varnish](https://gitlab.com/strowi/varnish)

Docker-Image containing:

* [Varnish 6.0.5](https://www.varnish-cache.org)
* [Varnish-Modules](https://github.com/varnish/varnish-modules.git)
* [libvmod-re](https://code.uplex.de/uplex-varnish/libvmod-re.git)
* [varnish-exporter](https://github.com/jonnenauha/prometheus_varnish_exporter) listening on Port `9131`.
* [varnish_reload.sh](./src/usr/local/bin/varnish_reload.sh) - script to reload varnish-config
* [be_state.sh](./src/usr/local/bin/be_state.sh) - simple script to change backend-status

Opposed to other solutions the varnish-exporter is run in a separate
container sharing `/var/lib/varnish`.

## Usage

You can export variables that will be used to start varnish:

* `BIND_PORT` - port to bind to
* `VCL_CONFIG` - varnish config file to start
* `VARNISHD_PARAMS` - any additional parameter

This will start the [docker-entrypoint.sh](./src/docker-entrypoint.sh):

```bash
/usr/sbin/varnishd -P /var/run/varnishd.pid \
  -F \
  -a $BIND_PORT \
  -f $VCL_CONFIG \
  -s malloc,$CACHE_SIZE \
  $VARNISHD_PARAMS
```
Example: (docker-compose.yml)[./docker-compose.yml]

### Updating Varnish-Config

Usually you don't want to restart the whole container for updates of the varnish-config because you would empty out the cache.

So we decided to create a separate folder for the configuration, sync that to the mounted `./src`-folder. 
And then just run the following to reload the config:

```bash
~> docker-compose exec -T varnish varnish_reload.sh -m0 /etc/varnish/default.vcl
```

## Docker Image

Should be available on docker and gitlab:

* [strowi/varnish:latest](https://hub.docker.com/repository/docker/strowi/varnish)
* [registry.gitlab.com/strowi/varnish:latest](https://gitlab.com/strowi/varnish)
