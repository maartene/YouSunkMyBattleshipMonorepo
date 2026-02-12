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
eval "$DOCKER_CMD build -f infrastructure/wsmirror/Dockerfile -t ws-mirror:latest infrastructure/wsmirror"
eval "$DOCKER_CMD run --rm -d -p 8080:8080 --name ws-mirror-test ws-mirror:latest"
sleep 1s
echo "Run tests"
swift build
swift test
echo "Cleanup"
eval "$DOCKER_CMD stop ws-mirror-test"
eval "$DOCKER_CMD image rm ws-mirror:latest --force"
echo "Done"