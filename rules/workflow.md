# Workflow & Pivot Discipline (v2)

## Core Workflow
0. Consent Gate — Before interacting with a new host/port, `export CTF_ALLOWED=1` (or set `CTF_SKIP_GUARD=1` to bypass), ensure the allowlist entry exists (wildcard `*` by default), run `scripts/ctf_guard.py`, and log the outcome in `notes.md`.
1. Plan — Draft a 3–7 step ranked plan. Audit handouts, identify reusable helpers, confirm platform/ABI compatibility. Verify `TOOLKIT_ROOT` (default `~/ctf_toolkit/standard`), run `scripts/sync_toolkit.sh` if the manifest hash differs, and record the sync timestamp + checksum in the Minimal Block before the first probe.
2. Structure Sweep — Model the surface before coding: sketch state diagrams, padding/length rules, truncation, invariants, and boundary behaviours (empty, single-byte, block-size ±1). Capture at least one cheap probe that confirms the model (e.g., hash of empty input) and log expected signals/controls in the ledger.
3. Probe — Design the smallest high‑signal test for the active hypothesis. Prefer vetted tools before bespoke scripts. Bundle related micro-checks with the Quick Probe template instead of emitting separate stanzas when they pursue the same discriminator.
4. Validate — Capture decisive evidence (excerpt, offsets, traces) in `artifacts/` with clear paths.
5. Interpret — Mark each result signal or null; update the hypothesis ledger and reorder priorities.
6. Decide — Continue, branch, or drop. Document the decision and the next action before executing it.
   - Deterministic rejections (`[DENIED]`, identical error banners, etc.) count as null outcomes. Update the ledger *before* trying a different payload or capability chain.
   - When a UI banner claims “already registered” or “invalid”, run one cheap discriminator (alternate encoding, Unicode homoglyph, replaying the captured request data) to prove the backend really blocks the path before abandoning the branch.
  - When narrative hint channels surface (NPC consoles, help banners), summarize their instructions in the current probe and translate them into actionable steps prior to new experiments.
  - When you escalate into a new execution context (new user, container, VM), pause to rerun lightweight recon using the toolkit helpers (`scripts/fetch_linpeas.sh` output, local enumeration). Log the context switch and refresh hypotheses before resuming exploitation.
7. Flag‑Path Sweep — After arbitrary read or RCE, immediately check standard flag locations.
8. Execution Discipline — Update `notes.md` after every probe *before* running the next. Write concise summaries manually. Log any helper you do fetch-on-demand (script name, purpose, source). If a required helper is missing or outdated, document the fallback (temporary script, manual step) and schedule a sync when time permits.

**Lightweight Track (optional)** — When the objective is a single, low-effort confirmation expected to finish within ~15 minutes, you may:
- Log a one-line plan and single hypothesis with explicit justification (`notes.md` → Pivot notes) rather than building a full roster.
- Use one Quick Probe Bundle to cover all verification commands.
- Mark the track as closed once the decisive evidence is captured (still run Consent Gate + toolkit check).
Document the choice in `notes.md` so reviewers know why the reduced ceremony was used.

## Stall & Pivot Discipline
- Hash‑null detector — if two probes yield identical responses, treat as null absent a new hypothesis.
- Default timeboxes — Web 5–8 min; RE/PWN 10–15; Crypto 5–10. Log expiry and pivot/renew explicitly.
- Pivot triggers — repeated nulls, identical errors, tool gaps, or guardrail feedback. Document retired hypotheses and next priorities.
- Exploit rejections form an immediate pivot trigger on the second failure; either renew with a documented plan (e.g., follow freshly gathered hints) or drop the hypothesis.
- Research burst — On second stall, re‑read artifacts and `rules/`, search for theory/writeups, refresh the hypothesis roster, then resume.

## Hint Consolidation Checklist
- Capture verbatim instructions from hint-bearing commands (`node.truth`, `system.hint`, etc.) in the probe notes.
- Paraphrase them into a one-line action list and verify each step is executed or consciously deferred.
- If instructions specify data transforms (ordering, hashing, encoding), implement the transform before pivoting to alternative capability hunts.

## Strategy Arbitration
Score active hypotheses each cycle and pick the highest Value of Information (VoI) per unit cost:

```
score = P(success) * Impact(signal) / Cost(time + risk)
```

Pick the top score; if close, run the discriminator first.

## Autopivot Algorithm (pseudocode)

```
for h in active_hypotheses:
    if h.null_count >= 2 or h.timebox_expired():
        if h.justified_renewal():
            h.renew_timebox()
        else:
            h.decision = "drop"
            plan.reorder()
            continue
    run_smallest_decisive_probe(h)
    update_ledger(h)
```

Keep 3–5 hypotheses alive; avoid single‑path tunnel vision.
