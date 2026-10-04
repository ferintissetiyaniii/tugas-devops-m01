#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$APP_DIR/lib/common.sh"

VENV_DIR="$APP_DIR/.venv"
PORT="${PORT:-5000}"

log_info "[1/5] Memeriksa prasyarat..."
require_cmd python3
require_cmd pip3

log_info "[2/5] Membuat lingkungan virtual..."
if [[ ! -d "$VENV_DIR" ]]; then
    python3 -m venv "$VENV_DIR"
fi

log_info "[3/5] Memasang dependensi..."
# shellcheck source=/dev/null
source "$VENV_DIR/bin/activate"
pip install --upgrade pip -q
pip install flask -q

log_info "[4/5] Memeriksa port $PORT..."
if ! port_is_free "$PORT"; then
    die "Port $PORT sudah dipakai, tutup dulu aplikasinya!"
fi

log_info "[5/5] Selesai!"
log_info "Jalankan aplikasi: source .venv/bin/activate && python3 src/app.py"
