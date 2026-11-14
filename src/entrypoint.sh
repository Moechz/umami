#!/bin/sh
# TOS wrapper: Umami needs APP_SECRET at startup; hard-coding it in the compose
# file is forbidden, so generate one on first start and keep it on the volume.
set -u
set -e
mkdir -p /data
F=/data/app_secret
if [ ! -s "$F" ]; then
  head -c 32 /dev/urandom | base64 | tr -d '\n' > "$F"
fi
export APP_SECRET="$(cat "$F")"
exec docker-entrypoint.sh yarn start-docker
