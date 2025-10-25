#!/usr/bin/env bash
# Synchronise curated toolkit helpers into the operator cache.
# Default target: ${TOOLKIT_ROOT:-$HOME/ctf_toolkit/standard}
# Usage: scripts/sync_toolkit.sh [--manifest path] [--root path] [--dry-run]

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST_PATH="${ROOT_DIR}/toolkit-manifest.json"
TOOLKIT_ROOT="${TOOLKIT_ROOT:-$HOME/ctf_toolkit/standard}"
DRY_RUN=0
CLEAN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --manifest)
      MANIFEST_PATH="$2"
      shift 2
      ;;
    --root)
      TOOLKIT_ROOT="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --clean)
      CLEAN=1
      shift
      ;;
    --help|-h)
      cat <<'EOF'
Synchronise curated toolkit helpers into the operator cache.

Options:
  --manifest PATH   Alternate manifest file (default toolkit-manifest.json)
  --root PATH       Target toolkit directory (default $TOOLKIT_ROOT)
  --dry-run         Show planned actions without copying
  --clean           Delete files under the target root that are not in the manifest
  -h, --help        Show this help and exit
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

if [[ ! -f "${MANIFEST_PATH}" ]]; then
  echo "[!] Manifest not found: ${MANIFEST_PATH}" >&2
  exit 1
fi

PYTHON=${PYTHON:-python3}
if ! command -v "${PYTHON}" >/dev/null 2>&1; then
  echo "[!] python3 is required" >&2
  exit 1
fi

export ROOT_DIR MANIFEST_PATH TOOLKIT_ROOT DRY_RUN CLEAN

"${PYTHON}" - <<'PY'
import json
import os
import shutil
import sys
from pathlib import Path

root_dir = Path(os.environ["ROOT_DIR"])
manifest_path = Path(os.environ["MANIFEST_PATH"])
toolkit_root = Path(os.environ["TOOLKIT_ROOT"]).expanduser()
dry_run = os.environ.get("DRY_RUN", "0") == "1"
clean = os.environ.get("CLEAN", "0") == "1"

with manifest_path.open("r", encoding="utf-8") as handle:
    manifest = json.load(handle)

toolkit_dir = manifest.get("toolkit_root", "toolkit")
source_root = (root_dir / toolkit_dir).resolve()

def sha256(path: Path) -> str:
    import hashlib

    hasher = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(65536), b""):
            hasher.update(chunk)
    return hasher.hexdigest()

files = manifest.get("files", [])
if not files:
    print("[!] Manifest contains no files", file=sys.stderr)
    sys.exit(1)

manifest_hash = sha256(manifest_path)

print(f"[+] Toolkit manifest: {manifest_path} (sha256={manifest_hash})")
print(f"[+] Source root: {source_root}")
print(f"[+] Target root: {toolkit_root}")

toolkit_root.mkdir(parents=True, exist_ok=True)

managed_paths = set()
synced = 0
skipped = 0
for entry in files:
    rel_path = entry["path"]
    expected_hash = entry["sha256"]
    mode = entry.get("mode", "0644")
    source = source_root / rel_path
    target = toolkit_root / rel_path

    managed_paths.add(Path(rel_path))

    if not source.exists():
        print(f"[!] Missing source: {source}", file=sys.stderr)
        continue

    target.parent.mkdir(parents=True, exist_ok=True)

    needs_copy = True
    if target.exists():
        try:
            current_hash = sha256(target)
            if current_hash == expected_hash:
                needs_copy = False
        except OSError as exc:
            print(f"[!] Failed to hash {target}: {exc}", file=sys.stderr)

    if needs_copy:
        action = "copy" if not dry_run else "would copy"
        print(f"[*] {action} {rel_path}")
        if not dry_run:
            shutil.copy2(source, target)
            os.chmod(target, int(mode, 8))
        synced += 1
    else:
        print(f"[-] up-to-date {rel_path}")
        skipped += 1

print(f"[=] Completed: synced={synced} skipped={skipped} dry_run={dry_run}")

extras = []
for candidate in toolkit_root.rglob("*"):
    if candidate.is_file():
        rel = candidate.relative_to(toolkit_root)
        if rel not in managed_paths:
            extras.append(rel)

if extras:
    if clean and not dry_run:
        for rel in extras:
            target = toolkit_root / rel
            try:
                target.unlink()
                print(f"[x] removed extra {rel}")
            except OSError as exc:
                print(f"[!] failed removing {rel}: {exc}", file=sys.stderr)
    else:
        joined = ", ".join(str(r) for r in extras)
        print("[!] extra files present (use --clean to delete):", joined)
PY
