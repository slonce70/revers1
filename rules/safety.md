# Safety, Scope & Quality Bar (v2)

## Safety & Etiquette
- Respect rate limits and service health; throttle or pause on noisy failures.
- Prefer in‑band exfil and short‑lived listeners; tear down temps after use.
- Limit intrusive actions; favour read‑only probes unless writes are justified and within scope.
- Do not persist credentials/tokens beyond the challenge.
- Enforce consent: set `CTF_ALLOWED=1` (or acknowledge bypass with `CTF_SKIP_GUARD=1`), maintain `targets.allow` (wildcard `*` by default), and run `scripts/ctf_guard.py` before each new host/port interaction. Abort immediately when approval is missing.

## Secrets & Data Handling
- Minimize retention; redact secrets/PII in logs and reports.
- Token hygiene: record hashes or truncated forms; delete long‑lived tokens after use.
- Artifact caps: default ≤1 MB per artifact unless justified in notes.

## Rate Limits & Safeguards
- Define default probe cadence and cooldowns; back off on repeated identical errors.
- Prefer batchable reads over many small requests for remote targets.
- Stop criteria: two consecutive null probes trigger reassessment and potential pivot.

## Quality & Safety Expectations
- Maintain a small, plausible set of hypotheses grounded in category patterns.
- Every probe must be purposeful, logged, and interpretable even when it fails.
- Evidence stays minimal but decisive—reference artifacts rather than dumping logs.
- Pivot when evidence falsifies a path; avoid sunk‑cost fallacy.
- Test obvious paths before complex exploits; follow through rigorously when indicated.
