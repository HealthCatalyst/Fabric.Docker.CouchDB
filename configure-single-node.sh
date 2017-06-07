#!/bin/bash

set -e

echo "enable cluster"
curl "http://$COUCHDB_USER:$COUCHDB_PASSWORD@couchdb1:5984/_cluster_setup" -H 'Content-Type: application/json' -H 'Accept: application/json' --data-binary "{\"action\":\"enable_cluster\",\"username\":\"$COUCHDB_USER\",\"password\":\"$COUCHDB_PASSWORD\",\"bind_address\":\"0.0.0.0\",\"port\":5984}" --compressed

echo "finish cluster"
curl "http://$COUCHDB_USER:$COUCHDB_PASSWORD@couchdb1:5984/_cluster_setup" -H 'Content-Type: application/json' -H 'Accept: application/json' --data-binary "{\"action\":\"finish_cluster\"}" --compressed

