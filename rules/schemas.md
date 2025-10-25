# Minimal Machine Formats (v2)

Lightweight JSON shapes for automation and sanity checks. Required fields stay minimal; optional fields add discipline without noise.

## Hypothesis Ledger Entry (JSON)
```json
{
  "id": "H1",
  "name": "SSRF to metadata",
  "priority": "H",
  "positive_probe": "GET /fetch?u=http://169.254.169.254",
  "negative_control": "GET /fetch?u=http://127.0.0.1",
  "null_count": 0,
  "decision": "continue",
  "timebox_ends": "2025-10-20T20:10:00Z",
  "category": "Web",
  "notes": "Expect IMDSv2 token; fall back to IMDSv1"
}
```
Required: id, name, priority, positive_probe, negative_control, null_count, decision.Optional: timebox_ends, category, notes.

## Probe Log Entry (JSON)
```json
{
  "ts": "2025-10-20T19:55:00Z",
  "hypothesis_id": "H1",
  "probe_id": "P1",
  "title": "Request instance metadata over SSRF",
  "design": "Expect IMDS token leak; negative control to 127.0.0.1 should be blocked",
  "command": "curl 'https://target/fetch?u=http://169.254.169.254/latest/meta-data/iam/security-credentials/'",
  "exit_code": 0,
  "evidence_path": "artifacts/h1_p1.txt",
  "expected_signal": "token string or metadata path list",
  "success_criterion": "non-empty AWS role name present",
  "interpretation": "signal",
  "decision": "continue",
  "rules_consulted": ["rules/category-heuristics.md#Web","rules/workflow.md#Stall-&-Pivot"]
}
```
Required: ts, hypothesis_id, design, command, exit_code, evidence_path, interpretation, decision.Optional: probe_id, title, expected_signal, success_criterion, rules_consulted.
