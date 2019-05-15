#!/bin/bash

HOST="$1"
HEALTH="$2"


echo "# looking for backend containing ${HOST}"
BACKEND="$(varnishadm backend.list|awk '{print $1}'|grep ${HOST})"

echo "# setting varnish-backend on ${BACKEND} to ${HEALTH}"
varnishadm backend.set_health ${BACKEND} ${HEALTH}
