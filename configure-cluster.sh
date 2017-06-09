#!/bin/bash

set -e

response=$(curl "http://$COUCHDB_USER:$COUCHDB_PASSWORD@couchdb1:5984/_membership")

echo "$response"

case "$response" in
	*"couchdb3"*) 
		echo "cluster is already configured, exiting."
		;;
	*)
		echo "enable cluster"
		curl "http://$COUCHDB_USER:$COUCHDB_PASSWORD@couchdb1:5984/_cluster_setup" -H 'Content-Type: application/json' -H 'Accept: application/json' \
			--data-binary "{\"action\":\"enable_cluster\",\"username\":\"$COUCHDB_USER\",\"password\":\"$COUCHDB_PASSWORD\",\"bind_address\":\"0.0.0.0\",\"port\":5984}" --compressed

		echo "enable cluster for couchd2"
		curl "http://$COUCHDB_USER:$COUCHDB_PASSWORD@couchdb1:5984/_cluster_setup" -H 'Content-Type: application/json' -H 'Accept: application/json'  \
			--data-binary "{\"action\":\"enable_cluster\",\"username\":\"$COUCHDB_USER\",\"password\":\"$COUCHDB_PASSWORD\",\"bind_address\":\"0.0.0.0\",\"port\":5984,\"remote_node\":\"couchdb2\",\"remote_current_user\":\"$COUCHDB_USER\",\"remote_current_password\":\"$COUCHDB_PASSWORD\"}" --compressed

		./wait-for-it.sh couchdb2:5984 -t 300 -- echo "couchdb2 is up"

		echo "add node couchdb2"
		curl "http://$COUCHDB_USER:$COUCHDB_PASSWORD@couchdb1:5984/_cluster_setup" -H 'Content-Type: application/json' -H 'Accept: application/json' \
			--data-binary "{\"action\":\"add_node\",\"username\":\"$COUCHDB_USER\",\"password\":\"$COUCHDB_PASSWORD\",\"host\":\"couchdb2\",\"port\":5984}" --compressed

		echo "enable cluster for couchdb3"
		curl "http://$COUCHDB_USER:$COUCHDB_PASSWORD@couchdb1:5984/_cluster_setup" -H 'Content-Type: application/json' -H 'Accept: application/json' \
			--data-binary "{\"action\":\"enable_cluster\",\"username\":\"$COUCHDB_USER\",\"password\":\"$COUCHDB_PASSWORD\",\"bind_address\":\"0.0.0.0\",\"port\":5984,\"remote_node\":\"couchdb3\",\"remote_current_user\":\"$COUCHDB_USER\",\"remote_current_password\":\"$COUCHDB_PASSWORD\"}" --compressed

		./wait-for-it.sh couchdb3:5984 -t 300 -- echo "couchdb3 is up"

		echo "add node for couchdb3"
		curl "http://$COUCHDB_USER:$COUCHDB_PASSWORD@couchdb1:5984/_cluster_setup" -H 'Content-Type: application/json' -H 'Accept: application/json' \
			--data-binary "{\"action\":\"add_node\",\"username\":\"$COUCHDB_USER\",\"password\":\"$COUCHDB_PASSWORD\",\"host\":\"couchdb3\",\"port\":5984}" --compressed

		echo "finish cluster"
		curl "http://$COUCHDB_USER:$COUCHDB_PASSWORD@couchdb1:5984/_cluster_setup" -H 'Content-Type: application/json' -H 'Accept: application/json' \
			--data-binary "{\"action\":\"finish_cluster\"}" --compressed
		;;
esac

