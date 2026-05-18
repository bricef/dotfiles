#!/usr/bin/env bash
# Running Docker containers (graceful fallback if docker missing/down).

set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "docker not installed"
  exit 0
fi

if ! docker info >/dev/null 2>&1; then
  echo "docker daemon not reachable"
  exit 0
fi

if [ -z "$(docker ps -q)" ]; then
  echo "No running containers"
  exit 0
fi

docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}' | head -20
