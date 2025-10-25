#!/usr/bin/env python3
"""Consent gate for autonomous CTF actions.

Usage: scripts/ctf_guard.py <target> [<port>]

Checks:
- Environment variable CTF_ALLOWED must equal "1".
- targets.allow must list the target (and optional port range) explicitly.

Exit code 0 means approved. Non-zero aborts the action.
"""

import ipaddress
import os
import sys
from pathlib import Path

ALLOW_FILE = Path(__file__).resolve().parent.parent / "targets.allow"


def usage() -> int:
    print("Usage: scripts/ctf_guard.py <target> [<port>]")
    return 1


def load_allowlist():
    if not ALLOW_FILE.exists():
        print(f"Allowlist missing: {ALLOW_FILE}")
        return []
    entries = []
    for raw in ALLOW_FILE.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        entries.append(line)
    return entries


def normalize_host(host: str) -> str:
    try:
        return str(ipaddress.ip_address(host))
    except ValueError:
        return host.lower()


def entry_matches(entry: str, host: str, port: str | None) -> bool:
    parts = entry.split()
    if not parts:
        return False
    entry_host = normalize_host(parts[0])
    host_match = entry_host == host
    if not host_match:
        return False
    if port is None or len(parts) == 1:
        return True
    for spec in parts[1:]:
        if "-" in spec:
            start, end = spec.split("-", 1)
            if start.isdigit() and end.isdigit() and int(start) <= int(port) <= int(end):
                return True
        elif spec.isdigit() and spec == port:
            return True
    return False


def main(argv: list[str]) -> int:
    if len(argv) not in {2, 3}:
        return usage()

    if os.environ.get("CTF_SKIP_GUARD") == "1":
        print("Guard bypassed via CTF_SKIP_GUARD=1 (use with caution).")
        return 0

    ctf_allowed = os.environ.get("CTF_ALLOWED")
    if ctf_allowed != "1":
        print("CTF_ALLOWED=1 not set; aborting.")
        return 2

    host = normalize_host(argv[1])
    port = argv[2] if len(argv) == 3 else None

    allow_entries = load_allowlist()
    if not allow_entries:
        print("Allowlist empty; add entries to targets.allow before proceeding.")
        return 3

    for entry in allow_entries:
        if entry.strip() == "*":
            print("Consent granted for all targets via wildcard entry '*'.")
            return 0
        if entry_matches(entry, host, port):
            print(f"Consent granted for {host}:{port or '*'} via {entry}")
            return 0

    print(f"No allowlist entry for {host}:{port or '*'}; aborting.")
    return 4


if __name__ == "__main__":
    sys.exit(main(sys.argv))
