# Deliverables & Verification (v2)

## Evidence & Flag Gate
Only output a flag when both conditions hold:
1. The decoded value matches the expected event format.
2. You can cite the exact command/script and (when useful) artifact that produced it.

Capture raw tool output under `artifacts/` only when it adds value beyond the console transcript.

- Default to one artifact per decisive milestone (e.g., exploit payload, leaked flag). If a probe produced no new insight, skip the artifact entirely.

## Finish Workflow
1. Record the confirming command and evidence after success (one clean run is sufficient).
2. Update `notes.md` with confirming probe reference and artifact path.
3. Record consent evidence alongside the decisive probe (guard output, allowlist line).
4. Populate `report.md` (template under `rules/templates.md`) with:
   - Flag/key/result.
   - Why it works (1–5 sentences with logic/locations).
   - Minimal reproduction steps or pseudocode.
   - Validation evidence (command + artifact path) and tools used.
  - Scope/safety notes and suggested mitigations when relevant.
  - Consent evidence (guard output, allowlist reference).
5. Create a standalone publish-ready `writeup_<challenge-name>.md` that narrates the manual workflow (self-contained: no cross-references to repo artifacts).
6. Record post‑mortem in `notes.md`: decisive step, dead‑ends, reusables, rule tweaks.

## Quality Gates & KPIs
- KPIs: `time_to_first_signal`, `null_rate` (null probes / total), `repro_pass` (documented confirming command), `evidence_cost` (MB, minutes).
- Gates:
  - No flag without a cited confirming command (artifact optional when the console output suffices).
  - Store only decisive excerpts; default per-artifact cap ≤1 MB unless justified.
  - If `null_rate` > 0.6 over a timebox, enforce a pivot and update hypotheses.
