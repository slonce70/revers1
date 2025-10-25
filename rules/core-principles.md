# Core Principles (v2)

Mission: find the success signal fast, safely, and reproducibly. Think → Plan (3–7 bullets) → Probe → Validate → Interpret → Decide. Prefer the smallest decisive test over brute force. Halt once the flag is confirmed, then re‑verify from a clean state.

## Boundaries & Research
- Single mission: extract the explicit flag/key/condition with minimal decisive actions.
- Stay strictly in scope; writes allowed only for instrumentation/observation when justified.
- Use external documentation proactively; log Question → URL → Insight in `notes.md` when you consult outside sources.
- Run the consent gate before interacting with each new target/port: `export CTF_ALLOWED=1` (or set `CTF_SKIP_GUARD=1` intentionally), ensure `targets.allow` has an entry (`*` wildcard by default), and log the guard outcome.

## The Core Four (enforced)
1. Minimal Block — Capture goal signal, scope/assets, constraints, connectivity, and config triage before the first probe.
2. Hint‑to‑Action — Translate each explicit hint into at least one concrete probe before generic enumeration.
3. Initial Plan — Maintain a living 3–7 step plan ranked by value-of-information. Update it after each major discovery or pivot.
4. Per‑Probe Logging — Each action records design → command → evidence → interpretation → decision → Rules consulted.

## Multi‑Path Discipline
- Keep 3–5 active hypotheses with positive/negative controls and null counters.
- Use micro timeboxes (default: Web 5–8 min; RE/PWN 10–15; Crypto 5–10). On expiry, pivot or renew with justification.
- Use discriminators to collapse branches early; avoid sunk‑cost fallacy.
- Treat two identical responses as a hash‑null unless a new hypothesis changes expectations.

## Workspace Obligations
Maintain the reproducible tree: `artifacts/`, `scripts/`, `tools/`, `notes.md`, `report.md`, `targets.allow`. Create missing directories before use. Execute the consent gate and environment snapshot upfront (`scripts/ctf_guard.py`, `scripts/bootstrap_environment.sh`); fetch any additional helpers (wordlists, privesc scripts, toolkit sync) only when a hypothesis requires them. Record an environment snapshot at session start and whenever you pivot into a materially different execution context (e.g., container, chroot, alternate user). Sweep existing helpers before authoring new tooling.
