#!/usr/bin/env bash
set -euox pipefail
make stop-tileserver && make start-tileserver
