# Varnish-Image

Repo-Url: [https://gitlab.com/strowi/varnish](https://gitlab.com/strowi/varnish)

## Docker Image

Should be available on docker and gitlab:

* [strowi/varnish:latest](https://hub.docker.com/repository/docker/strowi/varnish)
* [registry.gitlab.com/strowi/varnish:latest](https://gitlab.com/strowi/varnish)

### containing

* [Varnish 6.0.7](https://www.varnish-cache.org)
* [Varnish-Modules](https://github.com/varnish/varnish-modules.git)
* [libvmod-re](https://code.uplex.de/uplex-varnish/libvmod-re.git)
* [varnish-exporter 1.5.2](https://github.com/jonnenauha/prometheus_varnish_exporter) listening on Port `9131`.
* [varnish_reload.sh](./src/usr/local/bin/varnish_reload.sh): script to reload varnish-config
* [be_state.sh](./src/usr/local/bin/be_state.sh): simple script to change backend-status (uses grep to find backend)
* [varnishtop_metrics.sh](./src/usr/local/bin/varnishtop_metrics.sh): export top backend requests as prometheus metrics (node-exporter/textfile)

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

### be_state.sh

Since above `varnish_reload.sh`  appends a timestamp to the config-name each backends name changes with a config-reload:

```shell
> varnishadm backend.list
Backend name                   Admin      Probe                Last updated
reload_20210105_104634.backend1 probe      Healthy             3/3 Tue, 05 Jan 2021 10:46:38 GMT
reload_20210105_104634.backend2 probe      Healthy             3/3 Tue, 05 Jan 2021 10:46:38 GMT
reload_20210105_104634.backend3 probe      Healthy             3/3 Tue, 05 Jan 2021 10:46:38 GMT
```

This can get very annoying when you need to disable single backends. On multiple server even more so.

So `be_state.sh` takes a host and a status as argument and greps for the host settings the status.

```shell
~> be_state.sh backend1 sick
# looking for backend containing backend1
reload_20210105_104634.backend1
# setting varnish-backend on  to sick
~> varnishadm. backend.list
Backend name                   Admin      Probe                Last updated
reload_20210105_104634.backend1 probe      sick             3/3 Tue, 05 Jan 2021 10:46:38 GMT
```
