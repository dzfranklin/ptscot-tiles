#!/usr/bin/env bash
set -euox pipefail

set +e
make stop-db
make stop-postserve
make stop-maputnik
make stop-tileserver
set -e

make start-db
make start-postserve
make start-maputnik

make start-tileserver

set +x
echo ""
echo ""
echo "***********************************************************"
echo "* Tileserver started at http://localhost:8080/"
echo "* To view style in maputnik go to http://localhost:8088 and open the URL http://localhost:8080/styles/OSM%20OpenMapTiles/style.json"
echo "***********************************************************"
