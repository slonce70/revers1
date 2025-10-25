#!/usr/bin/env bash
# Download linpeas into tools/ with reproducible provenance.
# Usage: scripts/fetch_linpeas.sh [output-path]

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_DIR="${ROOT_DIR}/tools"
mkdir -p "${TOOLS_DIR}"

OUTPUT=${1:-"${TOOLS_DIR}/linpeas.sh"}
URL=${LINPEAS_URL:-"https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh"}

printf 'Fetching linpeas from %s\n' "${URL}"
curl -sSL "${URL}" -o "${OUTPUT}"
chmod +x "${OUTPUT}"

if command -v sha256sum >/dev/null 2>&1; then
  HASH=$(sha256sum "${OUTPUT}" | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
  HASH=$(shasum -a 256 "${OUTPUT}" | awk '{print $1}')
else
  HASH="(sha256 unavailable)"
fi

printf 'linpeas saved to %s (sha256:%s)\n' "${OUTPUT}" "${HASH}"
