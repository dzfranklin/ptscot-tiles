#!/usr/bin/env bash
set -euox pipefail
make build-style && docker compose stop tileserver-gl && docker compose up -d tileserver-gl

set +x
echo ""
echo ""
echo "***********************************************************"
echo "* Tileserver running at http://localhost:8080/"
echo "* To view style in maputnik go to http://localhost:8088 and open the URL http://localhost:8080/styles/OSM%20OpenMapTiles/style.json"
echo "***********************************************************"
