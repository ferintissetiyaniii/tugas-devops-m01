#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Muat fungsi bersama
source "$APP_DIR/lib/common.sh"

VENV_DIR="$APP_DIR/.venv"
PORT="${PORT:-5000}"

log_info "[1/5] Memeriksa prasyarat..."
require_cmd python3
require_cmd curl
port_is_free "$PORT" || die "port $PORT sudah dipakai proses lain"

echo "[1/5] Memeriksa prasyarat..."
command -v python3 >/dev/null || { echo "GAGAL: python3 tidak ditemukan."; exit 1; }
python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3,10) else 1)' || {
    echo "GAGAL: butuh Python 3.10+"
    exit 1
}

echo "[2/5] Menyiapkan virtual environment..."
[ -d "$VENV_DIR" ] || python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

echo "[3/5] Memasang dependensi..."
pip install --quiet --upgrade pip
pip install --quiet -r "$APP_DIR/requirements.txt"

echo "[4/5] Menjalankan aplikasi di port $PORT..."
PORT="$PORT" python3 "$APP_DIR/src/app.py" &
APP_PID=$!
trap 'kill "$APP_PID" 2>/dev/null || true' EXIT
sleep 3

echo "[5/5] Melakukan health check..."
if curl -fsS "http://127.0.0.1:$PORT/health" >/dev/null; then
    echo "✅ SUKSES: Aplikasi berjalan"
else
    echo "❌ GAGAL: Aplikasi tidak merespons"
    exit 1
fi

echo "Tekan Ctrl+C untuk berhenti"
wait "$APP_PID"
