#!/usr/bin/env bash
# cleanup.sh — stop containers, prune Docker resources, remove build/cache artifacts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

echo "=== Project cleanup: $PROJECT_ROOT ==="
echo ""

# --- Docker (skip gracefully if not installed) ---
if command -v docker &>/dev/null; then
    echo "=== Stopping running containers ==="
    RUNNING=$(docker ps -q 2>/dev/null || true)
    if [ -n "$RUNNING" ]; then
        docker stop $RUNNING
        echo "  stopped $(echo "$RUNNING" | wc -w) container(s)"
    else
        echo "  no running containers"
    fi
    echo ""

    echo "=== Removing stopped containers ==="
    docker container prune -f
    echo ""

    echo "=== Removing unused Docker resources (images, networks, build cache) ==="
    docker system prune -af --volumes
    echo ""
else
    echo "=== Docker not installed — skipping container cleanup ==="
    echo ""
fi

# --- Project artifact cleanup ---
echo "=== Removing node_modules, venv, caches, and Istio files ==="

REMOVED=0

remove_path() {
    if [ -e "$1" ]; then
        rm -rf "$1"
        echo "  removed: $1"
        REMOVED=$((REMOVED + 1))
    fi
}

while IFS= read -r -d '' dir; do
    remove_path "$dir"
done < <(find "$PROJECT_ROOT" -type d \( \
    -name node_modules -o \
    -name venv -o \
    -name .venv -o \
    -name .pytest_cache -o \
    -name __pycache__ \
    \) -print0 2>/dev/null)

while IFS= read -r -d '' file; do
    remove_path "$file"
done < <(find "$PROJECT_ROOT" -type f -name '*.pyc' -print0 2>/dev/null)

while IFS= read -r -d '' path; do
    remove_path "$path"
done < <(find "$PROJECT_ROOT" \( \
    -type f -iname '*istio*' -o \
    -type d -iname '*istio*' \
    \) -print0 2>/dev/null)

if [ "$REMOVED" -eq 0 ]; then
    echo "  nothing to remove — project is already clean"
fi

echo ""
echo "=== Cleanup complete ==="
