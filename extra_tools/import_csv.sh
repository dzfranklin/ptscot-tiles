#!/usr/bin/env bash
set -euo pipefail

input_file="$1"
table=$(basename "$input_file" | sed 's/\./_/')

dump_file=$(mktemp)
script_file=$(mktemp)
scratch_db=$(mktemp)
cat <<- EOF >"$script_file"
.bail on
.mode csv
.import "$input_file" "$table"
.schema "$table"
.output "$dump_file"
.dump
EOF

echo "Importing $table..."

psql.sh -c "DROP TABLE IF EXISTS $table;"

sqlite3 "$scratch_db" ".read $script_file"

sed -i 's/^PRAGMA .*;$//' "$dump_file"
sed -i 's/^BEGIN TRANSACTION;$//' "$dump_file"
sed -i 's/^COMMIT;$//' "$dump_file"

psql.sh --quiet -v ON_ERROR_STOP=1 -f "$dump_file"

echo "Imported $table."

rm "$dump_file"
rm "$script_file"
rm "$scratch_db"
