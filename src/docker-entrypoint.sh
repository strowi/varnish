#!/bin/sh

### start nginx in foreground
/usr/sbin/varnishd -P /var/run/varnishd.pid \
  -F \
  -a $BIND_PORT \
  -f $VCL_CONFIG \
  -s malloc,$CACHE_SIZE \
  -l 120m \
  $VARNISHD_PARAMS
