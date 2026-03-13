#!/bin/bash

# ============================================================
# SCM Application Launch Script
# Usage:
#   ./launch.sh             - Start the full stack
#   ./launch.sh --pull      - Git pull all repos (safe w/ local changes)
#   ./launch.sh --build     - Rebuild Docker images before starting
#   ./launch.sh --stop      - Stop all services gracefully
#   ./launch.sh --clean     - Stop all services AND wipe DB/cache volumes
#   ./launch.sh --logs      - Auto-open a new Terminal window to tail logs
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PULL_LATEST=false
BUILD_IMAGES=false
STOP_ONLY=false
CLEAN_VOLUMES=false
SHOW_LOGS=false

for arg in "$@"
do
    case $arg in
        --pull)   PULL_LATEST=true;   shift ;;
        --build)  BUILD_IMAGES=true;  shift ;;
        --stop)   STOP_ONLY=true;     shift ;;
        --clean)  CLEAN_VOLUMES=true; shift ;;
        --logs)   SHOW_LOGS=true;     shift ;;
    esac
done

echo "==================================="
echo "   SCM Application Stack Manager   "
echo "==================================="

# Helper: stop frontend by PID file or port fallback
stop_frontend() {
    if [ -f ".frontend.pid" ]; then
        FRONTEND_PID=$(cat .frontend.pid)
        pkill -TERM -P "$FRONTEND_PID" 2>/dev/null
        kill "$FRONTEND_PID" 2>/dev/null
        rm -f .frontend.pid
        echo "   Frontend stopped (PID $FRONTEND_PID)."
    else
        # Fallback: kill whatever holds port 3000
        FE_PID=$(lsof -ti :3000 2>/dev/null)
        if [ -n "$FE_PID" ]; then
            kill "$FE_PID" 2>/dev/null
            echo "   Frontend stopped (port-fallback PID $FE_PID)."
        else
            echo "   No frontend process found on :3000."
        fi
    fi
}

# ---------- STOP ----------
if [ "$STOP_ONLY" = true ]; then
    echo "=> Stopping backend (Docker Compose)..."
    docker compose down --remove-orphans

    echo "=> Stopping frontend (npm)..."
    stop_frontend

    echo "=> Stack stopped."
    exit 0
fi

# ---------- CLEAN ----------
if [ "$CLEAN_VOLUMES" = true ]; then
    echo "=> Stopping stack and wiping database/redis volumes..."
    docker compose down -v --remove-orphans

    echo "=> Stopping frontend (npm)..."
    stop_frontend

    echo "=> Volumes wiped. DB will start fresh on next launch."
    exit 0
fi

# ---------- PRE-FLIGHT: Docker daemon + clean state + port conflicts ----------
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker daemon is not running. Please start Docker Desktop and try again."
    exit 1
fi

echo "=> Ensuring a clean state (stopping any running compose containers)..."
docker compose down --remove-orphans

# Also remove any lingering manually-started containers that compose won't touch
echo "=> Removing any leftover named containers..."
for name in redis postgres django celery_worker celery_ml_worker celery_beat; do
    if docker ps -a --format '{{.Names}}' | grep -q "^${name}$"; then
        docker rm -f "$name" >/dev/null 2>&1
        echo "   Removed container: $name"
    fi
done

# ---------- PRE-FLIGHT: Port conflict check ----------
echo "=> Checking for port conflicts..."
PORTS_TO_CHECK=(8000 3000 5432)
CONFLICT=false
for PORT in "${PORTS_TO_CHECK[@]}"; do
    if lsof -Pi :"$PORT" -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "   ⚠️  Port $PORT is already in use by another process."
        CONFLICT=true
    fi
done
if [ "$CONFLICT" = true ]; then
    echo ""
    echo "   Please stop the conflicting process(es) and try again."
    echo "   Tip: you may have a leftover 'docker run' or 'npm start' still running."
    exit 1
fi

# ---------- GIT PULL (with stash safety) ----------
safe_pull() {
    local dir="$1"
    local original_dir
    original_dir="$(pwd)"
    cd "$dir" || return

    local stashed=false
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
        echo "   ⚠️  Local changes detected in $dir — stashing before pull..."
        git stash push -m "launch.sh auto-stash $(date +%Y%m%d%H%M%S)"
        stashed=true
    fi

    git pull

    if [ "$stashed" = true ]; then
        echo "   Restoring stashed changes in $dir..."
        git stash pop
    fi

    cd "$original_dir"
}

if [ "$PULL_LATEST" = true ]; then
    echo "=> Pulling latest changes..."
    for dir in ../scm_backend ../scm_frontend ../scm_ml; do
        if [ -d "$dir/.git" ]; then
            echo "   -> Updating $dir..."
            safe_pull "$dir"
        fi
    done
fi

# ---------- BUILD & START BACKEND (Docker Compose) ----------
COMPOSE_ARGS="-d"
if [ "$BUILD_IMAGES" = true ]; then
    echo "=> Rebuilding Docker images (no cache)..."
    COMPOSE_ARGS="--build $COMPOSE_ARGS"
fi

echo "=> Starting backend stack (Docker Compose)..."
docker compose up $COMPOSE_ARGS

# ---------- START FRONTEND (native npm) ----------
echo "=> Starting frontend (npm start)..."
cd ../scm_frontend || { echo "❌ scm_frontend directory not found!"; exit 1; }

echo "   Installing/verifying npm dependencies..."
npm install --silent

npm start &
FRONTEND_PID=$!
echo $FRONTEND_PID > ../.frontend.pid

cd "$SCRIPT_DIR"

if [ "$SHOW_LOGS" = true ]; then
    echo "=> Auto-opening log monitor in a new window..."
    osascript -e "tell app \"Terminal\" to do script \"cd '$SCRIPT_DIR' && docker compose logs -f\"" >/dev/null 2>&1
fi

echo ""
echo "==================================="
echo "   Stack is up and running! 🚀    "
echo "==================================="
echo "   Frontend:  http://localhost:3000"
echo "   Backend:   http://localhost:8000"
echo "   Admin:     http://localhost:8000/admin/"
echo ""
echo "   Useful commands:"
echo "   ./launch.sh --stop           Stop all services"
echo "   ./launch.sh --clean          Stop + wipe DB/cache data"
echo "   ./launch.sh --build          Rebuild Docker images"
echo "   ./launch.sh --pull           Pull latest git changes (stash-safe)"
echo "   ./launch.sh --logs           Open logs in a new window"
echo "   docker compose logs -f       View backend logs in this window"
echo "==================================="
