#!/usr/bin/env bash
# Stop containers and remove unused Docker resources.
# Also removes common local dev cruft from this project directory.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Project cleanup: $(basename "$SCRIPT_DIR") ==="

# Remove Python/Node/Istio artifacts from the project tree
echo "--- Removing local dev artifacts ---"
find "$SCRIPT_DIR" \
  \( -type d \( -name 'node_modules' -o -name 'venv' -o -name '.venv' -o -name 'env' -o -name '.pytest_cache' -o -name '__pycache__' -o -name 'istio' \) \
  -o -type f \( -name '*.pyc' -o -name '*.pyo' \) \
  -o -type f -iname '*istio*' \) \
  -print -prune -exec rm -rf {} + 2>/dev/null || true

# Docker cleanup (skip gracefully if Docker is not installed)
if ! command -v docker >/dev/null 2>&1; then
  echo "--- Docker not installed; skipping container cleanup ---"
  echo "=== Cleanup complete ==="
  exit 0
fi

echo "--- Stopping Docker Compose services (if any) ---"
for compose_file in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
  if [[ -f "$SCRIPT_DIR/$compose_file" ]]; then
    echo "Stopping stack: $compose_file"
    docker compose -f "$SCRIPT_DIR/$compose_file" down --remove-orphans 2>/dev/null || \
      docker-compose -f "$SCRIPT_DIR/$compose_file" down --remove-orphans 2>/dev/null || true
  fi
done

echo "--- Stopping all running containers ---"
running_ids="$(docker ps -q 2>/dev/null || true)"
if [[ -n "$running_ids" ]]; then
  docker stop "$running_ids"
else
  echo "No running containers."
fi

echo "--- Removing stopped containers ---"
stopped_ids="$(docker ps -aq 2>/dev/null || true)"
if [[ -n "$stopped_ids" ]]; then
  docker rm -f "$stopped_ids"
else
  echo "No containers to remove."
fi

echo "--- Pruning unused Docker resources ---"
docker system prune -af --volumes

echo "=== Cleanup complete ==="
