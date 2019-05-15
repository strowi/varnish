# Varnish-Image

Contains Varnish 6.0.1 and exporter (port: 9131).

Also contains the exporter to be started in a different container and shared `/var/lib/varnish`.

varnish is started with these parameters, which will have to be set via environment variable:
```
/usr/sbin/varnishd -P /var/run/varnishd.pid \
  -F \
  -a $BIND_PORT \
  -f $VCL_CONFIG \
  -s malloc,$CACHE_SIZE \
  $VARNISHD_PARAMS
```

includes: 
- varnish_reload.sh (reload / discard vcls )
