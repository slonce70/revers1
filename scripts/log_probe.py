#!/usr/bin/env python3
"""Append structured probe summaries to notes.md.

Usage:
    scripts/log_probe.py --id P1 --hypothesis H1 --title "Login oracle" \
        --design "Compare valid vs invalid" --command "ffuf ..." \
        --interpretation signal --decision continue \
        --rules rules/category-heuristics.md#Web \
        [--evidence artifacts/h1_p1.txt]

Only minimal validation is performed to keep the script lean.
"""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
from pathlib import Path
from typing import List, Optional


ROOT = Path(__file__).resolve().parent.parent
NOTES_PATH = ROOT / "notes.md"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Structured probe logger")
    parser.add_argument("--id", required=True, help="Probe identifier (e.g., P3)")
    parser.add_argument("--hypothesis", required=True, help="Hypothesis ID (e.g., H2)")
    parser.add_argument("--title", required=True, help="Short probe title")
    parser.add_argument("--design", required=True, help="Design / expectation summary")
    parser.add_argument("--command", required=True, help="Command executed")
    parser.add_argument(
        "--interpretation",
        required=True,
        choices=["signal", "null", "mixed"],
        help="Outcome interpretation",
    )
    parser.add_argument(
        "--decision",
        required=True,
        choices=["continue", "pivot", "drop", "success"],
        help="Next action decision",
    )
    parser.add_argument("--rules", action="append", default=[], help="Rules consulted (repeatable)")
    parser.add_argument("--evidence", help="Artifact path")
    parser.add_argument("--timebox", help="Timebox end (ISO8601)")
    parser.add_argument("--no-notes", action="store_true", help="Skip appending probe summary to notes.md")
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    timestamp = datetime.now(timezone.utc).isoformat()

    if not args.no_notes:
        append_notes(
            probe_id=args.id,
            hypothesis=args.hypothesis,
            title=args.title,
            design=args.design,
            command=args.command,
            interpretation=args.interpretation,
            decision=args.decision,
            rules=args.rules,
            evidence=args.evidence,
            timebox=args.timebox,
            timestamp=timestamp,
        )

    print(f"Logged probe {args.id} for hypothesis {args.hypothesis}")
    return 0


def append_notes(
    *,
    probe_id: str,
    hypothesis: str,
    title: str,
    design: str,
    command: str,
    interpretation: str,
    decision: str,
    rules: List[str],
    evidence: Optional[str],
    timebox: Optional[str],
    timestamp: str,
) -> None:
    if not NOTES_PATH.exists():
        return

    lines: List[str] = [
        "",
        f"### Probe {probe_id}: {title} ({hypothesis})",
        f"- Logged: {timestamp}",
        f"- Design: {design}",
        f"- Interpretation: {interpretation}",
        f"- Decision: {decision}",
    ]

    if timebox:
        lines.append(f"- Timebox: {timebox}")
    if rules:
        lines.append(f"- Rules: {', '.join(rules)}")
    if evidence:
        lines.append(f"- Evidence: {evidence}")

    lines.append("- Command:")
    lines.append("  ```")
    for cmd_line in command.splitlines():
        lines.append(f"  {cmd_line}")
    lines.append("  ```")

    with NOTES_PATH.open("a", encoding="utf-8") as notes_file:
        notes_file.write("\n".join(lines) + "\n")


if __name__ == "__main__":
    raise SystemExit(main())
