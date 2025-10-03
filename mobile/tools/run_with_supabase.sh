#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

ENV_FILE="${APP_DIR}/.env.local"
FLUTTER_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      if [[ $# -lt 2 ]]; then
        echo "--env-file requires a path" >&2
        exit 1
      fi
      ENV_FILE="$2"
      shift 2
      ;;
    --env-file=*)
      ENV_FILE="${1#*=}"
      shift
      ;;
    --)
      shift
      FLUTTER_ARGS+=("$@")
      break
      ;;
    *)
      FLUTTER_ARGS+=("$1")
      shift
      ;;
  esac
done

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "No env file found at ${ENV_FILE}. Create one with SUPABASE_URL/SUPABASE_ANON_KEY." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +a

SUPABASE_URL="${SUPABASE_URL:-}"
if [[ -z "${SUPABASE_URL}" && -n "${SUPABASE_HOST:-}" ]]; then
  SUPABASE_URL="https://${SUPABASE_HOST}"
fi

SUPABASE_PUBLISHABLE_KEY="${SUPABASE_PUBLISHABLE_KEY:-}"
if [[ -z "${SUPABASE_PUBLISHABLE_KEY}" ]]; then
  SUPABASE_PUBLISHABLE_KEY="${SUPABASE_ANON_KEY:-${ANON_KEY:-}}"
fi

if [[ -z "${SUPABASE_URL}" || -z "${SUPABASE_PUBLISHABLE_KEY}" ]]; then
  echo "Supabase URL and anon/publishable key are required." >&2
  exit 1
fi

cd "${APP_DIR}"

flutter run \
  --dart-define="SUPABASE_URL=${SUPABASE_URL}" \
  --dart-define="SUPABASE_PUBLISHABLE_KEY=${SUPABASE_PUBLISHABLE_KEY}" \
  "${FLUTTER_ARGS[@]}"
