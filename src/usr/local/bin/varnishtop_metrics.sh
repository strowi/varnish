#!/bin/bash


# exports varnishtop as prometheus metrics
# this way you can see the most requested backend routes
# not absolutely accurate, but good pointers
#
# varnish_berequrl_rate{url="/x/y"} 268.00
# varnish_berequrl_rate{url="/a/b"} 66.00


while sleep 60s; do
  varnishtop -1 -i BereqURL \
    |head -n 20 \
    |awk '{print "varnish_berequrl_rate{url=\"" $3 "\"} " $1 }' \
    > /var/lib/node_exporter/textfile/60s_varnishtop.prom
done;
