#!/bin/bash
for app_dir in /opt/apps/*/; do
  [ -f "$app_dir/docker-compose.yml" ] || continue
  cd "$app_dir"
  docker compose pull -q
  docker compose up -d --remove-orphans
done
