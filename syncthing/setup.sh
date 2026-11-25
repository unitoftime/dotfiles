#!/usr/bin/env bash
# Makes this machine's Syncthing match ./folders: creates each folder with its ignore list,
# keeps replaced or deleted files for 30 days, shares every folder with every paired device,
# and stops syncing folders not listed (their files stay on disk).
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

folders=$(grep -v '^\s*\(#\|$\)' "$here/folders")

# Removing a folder from Syncthing leaves its files alone. This also drops the ~/Sync starter
# folder Syncthing creates on first run.
for id in $(api config/folders | jq -r '.[].id'); do
  if ! awk '{print $1}' <<<"$folders" | grep -qxF "$id"; then
    api "config/folders/$id" -X DELETE >/dev/null
    echo "syncthing: stopped syncing $id (not in folders)"
  fi
done
rmdir ~/Sync 2>/dev/null || true

# Decline anonymous usage reporting, so the web UI doesn't ask.
api config/options -X PATCH -d '{"urAccepted": -1}' >/dev/null

while read -r id path ignores; do
  path=${path/#\~/$HOME}
  folder=$(jq -n --arg id "$id" --arg path "$path" --argjson devices "$devices" '{
    id: $id, label: ($path | split("/") | last), devices: $devices,
    versioning: {type: "trashcan", params: {cleanoutDays: "30"}}
  }')
  # An existing folder is never moved: pointing Syncthing at another directory makes it read
  # every file it synced as deleted. PATCH keeps the rest of its settings.
  if current=$(api "config/folders/$id" 2>/dev/null | jq -r .path); then
    [ "$current" = "$path" ] ||
      echo "syncthing: $id syncs $current, not $path; left as is (move it by removing the folder and accepting it again)"
    api "config/folders/$id" -X PATCH -d "$folder" >/dev/null
  else
    mkdir -p "$path"
    api "config/folders/$id" -X PUT -d "$(jq --arg path "$path" '. + {path: $path}' <<<"$folder")" >/dev/null
  fi
  if [ -n "${ignores:-}" ]; then
    (cd "$here" && cat ${ignores//,/ }) | jq -Rn '{ignore: [inputs]}' |
      api "db/ignores?folder=$id" -X POST -d @- >/dev/null
  fi
  echo "syncthing: $id -> $path"
done <<<"$folders"
