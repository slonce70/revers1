#!/usr/bin/env bash
# Bootstrap workspace baseline: capture environment snapshot and ensure core dirs exist.
# Usage: scripts/bootstrap_environment.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARTIFACT_DIR="${ROOT_DIR}/artifacts"
TMP_DIR="${ROOT_DIR}/tmp"

mkdir -p "${ARTIFACT_DIR}" "${TMP_DIR}"

SNAPSHOT_FILE="${ARTIFACT_DIR}/environment.txt"
TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u)"

run_section() {
  local title=$1
  shift || true
  echo "## ${title}"
  "$@"
  echo
}

run_version() {
  local cmd=$1
  local label=${2:-${cmd}}
  shift 2 || true
  if command -v "${cmd}" >/dev/null 2>&1; then
    echo "## ${label}"
    "${cmd}" "$@" 2>&1 | head -n 1 || true
    echo
  fi
}

{
  echo "# Environment snapshot ${TIMESTAMP}"
  echo

  if command -v uname >/dev/null 2>&1; then
    run_section "uname -a" uname -a
  fi

  if [[ -f /etc/os-release ]]; then
    run_section "/etc/os-release" cat /etc/os-release
  elif command -v sw_vers >/dev/null 2>&1; then
    run_section "sw_vers" sw_vers
  fi

  run_version python3 "python3 --version" --version
  run_version pipx "pipx --version" --version
  run_version pip3 "pip3 --version" --version
  run_version go "go version" version
  run_version rustc "rustc --version" --version
  run_version cargo "cargo --version" --version
  run_version nmap "nmap --version" --version
  run_version ffuf "ffuf --version" --version
  run_version gobuster "gobuster version" version
  run_version dirsearch "dirsearch --version" --version
  run_version hydra "hydra" -h
  run_version sqlmap "sqlmap --version" --version
  run_version msfconsole "msfconsole --version" --version
  run_version msfvenom "msfvenom --help" --help
  if command -v nc >/dev/null 2>&1; then
    echo "## nc path"
    command -v nc
    echo
  fi
  run_version socat "socat -V" -V

  if command -v ip >/dev/null 2>&1; then
    run_section "ip address" ip address
  elif command -v ifconfig >/dev/null 2>&1; then
    run_section "ifconfig" ifconfig
  fi

  if command -v python3 >/dev/null 2>&1; then
    echo "## python3 packages (subset)"
    python3 - <<'PY'
import pkgutil
important = {"pwntools", "requests", "paramiko"}
found = sorted(pkg.name for pkg in pkgutil.iter_modules() if pkg.name in important)
print("present:" if found else "present: none", ", ".join(found))
PY
    echo
  fi

  echo "## workspace"
  printf 'ARTIFACTS=%s\n' "${ARTIFACT_DIR}"
  printf 'TMP=%s\n' "${TMP_DIR}"
  printf 'WORDLISTS=%s\n' "${ROOT_DIR}/wordlists"
  printf 'TOOLS=%s\n' "${ROOT_DIR}/tools"
  echo
} >"${SNAPSHOT_FILE}"

printf 'Environment snapshot captured: %s\n' "${SNAPSHOT_FILE}"

if [[ "${BOOTSTRAP_SYNC_TOOLKIT:-1}" == "1" && -x "${ROOT_DIR}/scripts/sync_toolkit.sh" ]]; then
  echo "Running toolkit sync..."
  TOOLKIT_SYNC_OUTPUT="$(${ROOT_DIR}/scripts/sync_toolkit.sh 2>&1)"
  printf '%s\n' "${TOOLKIT_SYNC_OUTPUT}"
fi
