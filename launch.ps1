# ============================================================
# SCM Application Launch Script (Windows PowerShell)
# Usage:
#   .\launch.ps1             - Start the full stack
#   .\launch.ps1 --pull      - Git pull all repos (safe w/ local changes)
#   .\launch.ps1 --build     - Rebuild Docker images before starting
#   .\launch.ps1 --stop      - Stop all services gracefully
#   .\launch.ps1 --clean     - Stop all services AND wipe DB/cache volumes
#   .\launch.ps1 --logs      - Auto-open a new PowerShell window to tail logs
# ============================================================

param(
    [switch]$pull,
    [switch]$build,
    [switch]$stop,
    [switch]$clean,
    [switch]$logs
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $ScriptDir

Write-Host "===================================" -ForegroundColor Cyan
Write-Host "   SCM Application Stack Manager   " -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# ---------- Helper: Stop Frontend ----------
function Stop-Frontend {
    $pidFile = Join-Path $ScriptDir ".frontend.pid"
    if (Test-Path $pidFile) {
        $fePid = Get-Content $pidFile
        try {
            Stop-Process -Id $fePid -Force -ErrorAction SilentlyContinue
            Write-Host "   Frontend stopped (PID $fePid)." -ForegroundColor Green
        } catch {}
        Remove-Item $pidFile -Force
    } else {
        # Fallback: kill whatever holds port 3000
        $conn = Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue
        if ($conn) {
            Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
            Write-Host "   Frontend stopped (port-fallback PID $($conn.OwningProcess))." -ForegroundColor Green
        } else {
            Write-Host "   No frontend process found on :3000." -ForegroundColor Yellow
        }
    }
}

# ---------- STOP ----------
if ($stop) {
    Write-Host "=> Stopping backend (Docker Compose)..."
    docker compose down --remove-orphans
    Write-Host "=> Stopping frontend (npm)..."
    Stop-Frontend
    Write-Host "=> Stack stopped." -ForegroundColor Green
    exit 0
}

# ---------- CLEAN ----------
if ($clean) {
    Write-Host "=> Stopping stack and wiping database/redis volumes..."
    docker compose down -v --remove-orphans
    Write-Host "=> Stopping frontend (npm)..."
    Stop-Frontend
    Write-Host "=> Volumes wiped. DB will start fresh on next launch." -ForegroundColor Green
    exit 0
}

# ---------- PRE-FLIGHT: Docker daemon ----------
try {
    docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw }
} catch {
    Write-Host "❌ Docker daemon is not running. Please start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

# ---------- PRE-FLIGHT: Clean state ----------
Write-Host "=> Ensuring a clean state (stopping any running compose containers)..."
docker compose down --remove-orphans

Write-Host "=> Removing any leftover named containers..."
$knownContainers = @("redis", "postgres", "django", "celery_worker", "celery_ml_worker", "celery_beat")
foreach ($name in $knownContainers) {
    $exists = docker ps -a --format "{{.Names}}" | Where-Object { $_ -eq $name }
    if ($exists) {
        docker rm -f $name 2>&1 | Out-Null
        Write-Host "   Removed container: $name"
    }
}

# ---------- PRE-FLIGHT: Port conflict check ----------
Write-Host "=> Checking for port conflicts..."
$portsToCheck = @(8000, 3000, 5432)
$conflict = $false
foreach ($port in $portsToCheck) {
    $conn = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    if ($conn) {
        Write-Host "   ⚠️  Port $port is already in use by another process." -ForegroundColor Yellow
        $conflict = $true
    }
}
if ($conflict) {
    Write-Host ""
    Write-Host "   Please stop the conflicting process(es) and try again." -ForegroundColor Red
    Write-Host "   Tip: you may have a leftover 'docker run' or 'npm start' still running."
    exit 1
}

# ---------- GIT PULL (with stash safety) ----------
function Invoke-SafePull {
    param([string]$dir)
    $original = Get-Location
    Set-Location $dir

    $status = git status --porcelain 2>$null
    $stashed = $false
    if ($status) {
        Write-Host "   ⚠️  Local changes detected in $dir — stashing before pull..."
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        git stash push -m "launch.ps1 auto-stash $timestamp"
        $stashed = $true
    }

    git pull

    if ($stashed) {
        Write-Host "   Restoring stashed changes in $dir..."
        git stash pop
    }

    Set-Location $original
}

if ($pull) {
    Write-Host "=> Pulling latest changes..."
    foreach ($dir in @("../scm_backend", "../scm_frontend", "../scm_ml")) {
        if (Test-Path (Join-Path $dir ".git")) {
            Write-Host "   -> Updating $dir..."
            Invoke-SafePull $dir
        }
    }
}

# ---------- BUILD & START BACKEND (Docker Compose) ----------
$composeArgs = @("compose", "up", "-d")
if ($build) {
    Write-Host "=> Rebuilding Docker images (no cache)..."
    $composeArgs = @("compose", "up", "--build", "-d")
}

Write-Host "=> Starting backend stack (Docker Compose)..."
& docker @composeArgs

# ---------- START FRONTEND (native npm) ----------
Write-Host "=> Starting frontend (npm start)..."
$frontendDir = Join-Path $ScriptDir "..\scm_frontend"
if (-not (Test-Path $frontendDir)) {
    Write-Host "❌ scm_frontend directory not found!" -ForegroundColor Red
    exit 1
}

Set-Location $frontendDir
Write-Host "   Installing/verifying npm dependencies..."
npm install --silent

$feJob = Start-Process -FilePath "npm" -ArgumentList "start" -PassThru -WindowStyle Hidden
$feJob.Id | Out-File -FilePath (Join-Path $ScriptDir ".frontend.pid") -Encoding ascii

Set-Location $ScriptDir

if ($logs) {
    Write-Host "=> Auto-opening log monitor in a new window..." -ForegroundColor Cyan
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "docker compose logs -f"
}

Write-Host ""
Write-Host "===================================" -ForegroundColor Green
Write-Host "   Stack is up and running! 🚀    " -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host "   Frontend:  http://localhost:3000"
Write-Host "   Backend:   http://localhost:8000"
Write-Host "   Admin:     http://localhost:8000/admin/"
Write-Host ""
Write-Host "   Useful commands:"
Write-Host "   .\launch.ps1 --stop           Stop all services"
Write-Host "   .\launch.ps1 --clean          Stop + wipe DB/cache data"
Write-Host "   .\launch.ps1 --build          Rebuild Docker images"
Write-Host "   .\launch.ps1 --pull           Pull latest git changes (stash-safe)"
Write-Host "   .\launch.ps1 --logs           Open logs in a new window"
Write-Host "   docker compose logs -f        View backend logs in this window"
Write-Host "===================================" -ForegroundColor Green
