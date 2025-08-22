#!/usr/bin/env bash
set -euo pipefail

# Defaults
PORT="${PORT:-8888}"
IP="${IP:-0.0.0.0}"
ROOT_DIR="${ROOT_DIR:-/home/jovyan/work}"

mkdir -p "${ROOT_DIR}"

PASSWORD_OPT=""
TOKEN_OPT=""

# If a plain password is provided, hash it for Jupyter Server
if [[ -n "${JUPYTER_PASSWORD:-}" ]]; then
  HASHED=$(python3 - <<'PY'
from jupyter_server.auth import passwd
import os
pw = os.environ.get('JUPYTER_PASSWORD','')
print(passwd(pw) if pw else '')
PY
  )
  if [[ -n "${HASHED}" ]]; then
    PASSWORD_OPT="--ServerApp.password=${HASHED}"
  fi
fi

# If a token is provided, pass it through; otherwise Jupyter will auto-generate one
if [[ -n "${JUPYTER_TOKEN:-}" ]]; then
  TOKEN_OPT="--ServerApp.token=${JUPYTER_TOKEN}"
fi

exec jupyter lab \
  --ServerApp.ip="${IP}" \
  --ServerApp.port="${PORT}" \
  --ServerApp.allow_root=True \
  --ServerApp.open_browser=False \
  --ServerApp.root_dir="${ROOT_DIR}" \
  ${TOKEN_OPT} \
  ${PASSWORD_OPT}

