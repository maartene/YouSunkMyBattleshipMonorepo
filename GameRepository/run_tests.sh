#!/bin/bash
set -euo pipefail

# detect available compose command (podman/docker, with/without compose subcommand)
DOCKER_CMD=""
if command -v docker >/dev/null 2>&1 && docker version >/dev/null 2>&1; then
  DOCKER_CMD="docker"
elif command -v podman >/dev/null 2>&1 && podman version >/dev/null 2>&1; then
  DOCKER_CMD="podman"
fi

if [[ -z "$DOCKER_CMD" ]]; then
  echo "Error: neither podman nor docker found in PATH" >&2
  exit 1
fi

echo "Using docker command: $DOCKER_CMD"
echo "Starting containers"
eval "$DOCKER_CMD run --rm -d -p 27017:27017 --name db mongo:latest"
sleep 1s
echo "Run tests"
swift build
swift test
echo "Cleanup"
eval "$DOCKER_CMD stop db"
echo "Done"