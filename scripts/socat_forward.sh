#!/usr/bin/env bash
# Thin wrapper around socat for local port forwarding.
# Usage: scripts/socat_forward.sh <local_port> <target_host> <target_port> [listen_host]

set -euo pipefail

if ! command -v socat >/dev/null 2>&1; then
  printf 'socat is required but not installed\n' >&2
  exit 1
fi

if [[ $# -lt 3 || $# -gt 4 ]]; then
  printf 'Usage: %s <local_port> <target_host> <target_port> [listen_host]\n' "$0" >&2
  exit 1
fi

LOCAL_PORT=$1
TARGET_HOST=$2
TARGET_PORT=$3
LISTEN_HOST=${4:-127.0.0.1}

trap 'printf "Forward %s:%s → %s:%s stopped\n" "${LISTEN_HOST}" "${LOCAL_PORT}" "${TARGET_HOST}" "${TARGET_PORT}"' EXIT

printf 'Forwarding %s:%s → %s:%s (Ctrl+C to stop)\n' "${LISTEN_HOST}" "${LOCAL_PORT}" "${TARGET_HOST}" "${TARGET_PORT}"
socat "tcp-listen:${LOCAL_PORT},reuseaddr,fork,bind=${LISTEN_HOST}" "tcp:${TARGET_HOST}:${TARGET_PORT}"
