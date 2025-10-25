# Copyable Templates (v2)

These blocks keep logs consistent and machine‑friendly. Use them verbatim unless a section truly adds no value.

## `notes.md` — Minimal Block 3.0
```
# Notes

## Minimal Block
- Goal signal:
- Scope/assets:
- Constraints:
- Connectivity:
- Config triage:
- Toolkit root:
- Toolkit sync (timestamp & manifest hash):

## Consent & Allowlist
- CTF_ALLOWED exported at:
- targets.allow scope in effect:
- Guard command & outcome:

## Category Gate
- Candidates & discriminators:
  1) <category> — <discriminator probe>
  2) <category> — <discriminator probe>
  3) <category> — <discriminator probe>
- Decision summary: Chosen=<category>; Evidence=<artifact>; Rejected=<list>
- Rules consulted:

## Toolkit Prep Checklist
- Environment snapshot (artifacts/environment.txt) captured:
- Wordlists verified:
- Privilege-escalation helper ready:
- Standard scripts checksum (toolkit-manifest.json):
- Custom overrides loaded:

## Environment Snapshot
<path to artifacts/environment.txt>

## Plan (3–7 steps)
1.
2.
3.

## Hypothesis Ledger Summary
| ID | Focus | Control | Timebox | Nulls | State |
|----|-------|---------|---------|-------|-------|
|    |       |         |         |       |       |

## Pivot & Timebox Notes
- Last pivot reason:
- Active timers & expiries:
- Renewals justified by:

## Quick Probe Bundle Queue
- Pending discriminators:
- Logged bundle evidence:

## Flag Path & Wrap-up
- Flag sweep status:
- Checksum logged (if required):
- Report drafted:
```

## Probe Stanza (use `Probe <n>:` naming)
```
Probe <n>: <short title> (H<id>)
Design: <smallest decisive test + expected signal + negative control>
Command: <exact command/tool invocation>
Evidence: <artifacts path + brief excerpt>
Interpretation: <signal | null + rationale>
Decision: <continue | drop | pivot | success>
Rules consulted: rules/<file>#<section>, rules/<file>#<section>
Timebox: <end timestamp or n/a>
```

Use this block only when the outcome changes your understanding. Collapse repetitive null checks into a single summary or skip them entirely.

### Quick Probe Bundle (group related micro-tests)
```
Probe <n>: <bundle title> (H<id>)
Goal: <single discriminator the bundle resolves>
Checks:
  - `<cmd 1>` → <signal/null snippet>
  - `<cmd 2>` → … (add only what changed the picture)
Evidence: <optional artifact if one of the checks produced decisive data>
Interpretation: <overall signal | null + rationale>
Decision: <continue | drop | pivot | success>
Rules consulted: rules/<file>#<section>
Timebox: <end timestamp or n/a>
```

Add bundle entries whenever multiple quick checks share the same hypothesis discriminator; avoid creating one probe per shell line.

## Hypothesis Ledger — Markdown Row
```
| id | name | priority | positive_probe | negative_control | null_count | decision | timebox_ends |
|----|------|----------|----------------|------------------|------------|----------|--------------|
| H1 | SSRF to metadata | H | GET /fetch?u=http://169.254.169.254 | GET /fetch?u=http://127.0.0.1 | 0 | continue | 2025-10-20T20:10:00Z |
```

## CSV (save as `artifacts/ledger.csv`)
```
id,name,priority,positive_probe,negative_control,null_count,decision,timebox_ends
H1,SSRF to metadata,H,GET /fetch?u=http://169.254.169.254,GET /fetch?u=http://127.0.0.1,0,continue,2025-10-20T20:10:00Z
```

## `report.md` Skeleton
```
# Report

- Flag/Key/Result: <value>
- Why it works (1–5 sentences): <logic + locations>
- Minimal reproduction: <steps or pseudocode>
- Validation evidence: <command + artifacts path>
- Scope/safety notes: <limits, mitigations>
- Reflection: <breakthrough probe, dead‑ends, reusables>
```

Reminder: Populate `report.md` before closing out the mission. Lingering TODOs should block “Done”.

## Research Log (optional but encouraged)
```
Question: <what you needed to know>
Source: <URL>
Insight: <actionable 1–2 lines>
Action taken: < how it changed the plan or probe >
```

## Toolkit Prep (log snippet)
```
Toolkit prep:
- env snapshot: scripts/bootstrap_environment.sh → artifacts/environment.txt (checksum noted only if required)
- wordlists: scripts/ensure_wordlists.sh → wordlists/rockyou.txt
- privesc helpers: scripts/fetch_linpeas.sh → tools/linpeas.sh (checksum noted only if required)
- toolkit sync: scripts/sync_toolkit.sh --manifest toolkit-manifest.json → manifest checksum (optional) + timestamp
- forwards: scripts/socat_forward.sh 9999 172.17.0.2 8080 (teardown logged)
```

## Consent Log (notes.md)
```
Consent:
- env var: CTF_ALLOWED exported at <timestamp>
- allow scope: <target> <ports>
- guard: scripts/ctf_guard.py <target> <port> → Consent granted
```
