#!/usr/bin/env bash
# Makes this machine's Syncthing match ./folders: creates each folder with its ignore list,
# keeps replaced or deleted files for 30 days, and shares every folder with every paired device.
#
# Pairing stays manual, because each machine has to approve the other (see the Makefile for
# the steps); rerun `make syncthing` after pairing to share every folder with the new device.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)

key=$(syncthing cli config gui apikey get)
api() { curl -fsS -H "X-API-Key: $key" "http://127.0.0.1:8384/rest/$1" "${@:2}"; }

for _ in $(seq 50); do api noauth/health >/dev/null 2>&1 && break; sleep 0.2; done

# Every known device, this one included; folders are shared with all of them.
devices=$(api config/devices | jq '[.[] | {deviceID}]')

# Syncthing creates ~/Sync as a starter folder on first run; this setup doesn't use it.
api config/folders/default -X DELETE >/dev/null 2>&1 || true
rmdir ~/Sync 2>/dev/null || true

# Decline anonymous usage reporting, so the web UI doesn't ask.
api config/options -X PATCH -d '{"urAccepted": -1}' >/dev/null

grep -v '^\s*\(#\|$\)' "$here/folders" | while read -r id path ignores; do
  path=${path/#\~/$HOME}
  mkdir -p "$path"
  folder=$(jq -n --arg id "$id" --arg path "$path" --argjson devices "$devices" '{
    id: $id, label: ($path | split("/") | last), path: $path, devices: $devices,
    versioning: {type: "trashcan", params: {cleanoutDays: "30"}}
  }')
  # PATCH keeps the rest of an existing folder's settings; PUT creates a new one.
  if api "config/folders/$id" >/dev/null 2>&1; then method=PATCH; else method=PUT; fi
  api "config/folders/$id" -X "$method" -d "$folder" >/dev/null
  if [ -n "${ignores:-}" ]; then
    (cd "$here" && cat ${ignores//,/ }) | jq -Rn '{ignore: [inputs]}' |
      api "db/ignores?folder=$id" -X POST -d @- >/dev/null
  fi
  echo "syncthing: $id -> $path"
done
