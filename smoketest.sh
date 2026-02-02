#!/bin/bash
set -euo pipefail

# detect available compose command (podman/docker, with/without compose subcommand)
COMPOSE_CMD=""
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
elif command -v podman >/dev/null 2>&1 && podman compose version >/dev/null 2>&1; then
  COMPOSE_CMD="podman compose"
elif command -v podman-compose >/dev/null 2>&1; then
  COMPOSE_CMD="podman-compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
fi

if [ -z "$COMPOSE_CMD" ]; then
  echo "Error: neither podman-compose, podman compose, docker-compose nor docker compose found in PATH" >&2
  exit 1
fi

echo "Using compose command: $COMPOSE_CMD"
echo "Starting containers"
eval "$COMPOSE_CMD up --build --abort-on-container-exit --exit-code-from smoketest"
sleep 1s
echo "Cleanup"
eval "$COMPOSE_CMD down"