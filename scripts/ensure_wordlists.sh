#!/usr/bin/env bash
# Prepare commonly used wordlists (rockyou) for password attacks.
# Usage: scripts/ensure_wordlists.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORDLIST_DIR="${ROOT_DIR}/wordlists"
TARGET="${WORDLIST_DIR}/rockyou.txt"
TMP_GZ="${TARGET}.gz"

mkdir -p "${WORDLIST_DIR}"

if [[ -f "${TARGET}" ]]; then
  printf 'rockyou.txt already present at %s\n' "${TARGET}"
  exit 0
fi

copy_if_exists() {
  local src=$1
  if [[ -f "${src}" ]]; then
    printf 'Copying %s to %s\n' "${src}" "${TARGET}"
    cp "${src}" "${TARGET}"
    chmod 600 "${TARGET}" || true
    return 0
  fi
  return 1
}

decompress_if_exists() {
  local src=$1
  if [[ -f "${src}" ]]; then
    printf 'Decompressing %s → %s\n' "${src}" "${TARGET}"
    gunzip -c "${src}" >"${TARGET}"
    chmod 600 "${TARGET}" || true
    return 0
  fi
  return 1
}

if copy_if_exists /usr/share/wordlists/rockyou.txt; then
  exit 0
fi

if decompress_if_exists /usr/share/wordlists/rockyou.txt.gz; then
  exit 0
fi

ROCKYOU_URL=${ROCKYOU_URL:-"https://github.com/praetorian-inc/hob0rules/raw/master/wordlists/rockyou.txt.gz"}
printf 'Downloading rockyou from %s\n' "${ROCKYOU_URL}"
curl -sSL "${ROCKYOU_URL}" -o "${TMP_GZ}"

decompress_if_exists "${TMP_GZ}" && rm -f "${TMP_GZ}"

if [[ -f "${TARGET}" ]]; then
  printf 'rockyou.txt ready at %s\n' "${TARGET}"
else
  printf 'Failed to obtain rockyou.txt\n' >&2
  exit 1
fi
