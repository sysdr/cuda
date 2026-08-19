#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "== Docker cleanup =="
if command -v docker >/dev/null 2>&1; then
  CONTAINERS="$(docker ps -aq || true)"
  if [[ -n "${CONTAINERS}" ]]; then
    # Stop running containers first (ignore failures so cleanup still completes).
    docker stop ${CONTAINERS} >/dev/null 2>&1 || true
    docker rm -f ${CONTAINERS} >/dev/null 2>&1 || true
  fi

  # Remove unused images/containers/networks/volumes.
  docker system prune -af --volumes >/dev/null 2>&1 || true
  docker image prune -af >/dev/null 2>&1 || true
  docker container prune -f >/dev/null 2>&1 || true
else
  echo "Docker not found; skipping Docker cleanup."
fi

echo "== Repo cleanup (node/py caches / Istio) =="
shopt -s globstar nullglob

# Node/JS
rm -rf **/node_modules

# Python virtualenv + caches
rm -rf **/venv
rm -rf **/.pytest_cache
rm -rf **/__pycache__
rm -f  **/*.pyc

# Istio (common folder names)
rm -rf **/istio **/Istio **/istio-system **/.istio

echo "Cleanup complete."

