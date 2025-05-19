#!/usr/bin/env bash
set -euox pipefail
docker compose stop tileserver-gl && docker compose up -d tileserver-gl
