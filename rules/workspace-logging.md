# Workspace & Logging (v2)

## Reproducible Workspace
- Keep `artifacts/` for decisive evidence only; avoid routine noise.
- Put reusable tools in `scripts/` with a short docstring and stable interface.
- Use `notes.md` as a chronological log: minimal block, plan, hypotheses, probes, pivots, reflections.
- Maintain order of actions; timestamps are optional unless they add value.
- Summarize success in `report.md` once the flag path is verified.
- Create missing directories before first use and never delete user-provided assets.
- Log toolkit actions explicitly only when you fetch or build a helper on demand (script/tool name, purpose, source). Avoid pre-downloading large assets unless a hypothesis requires them.
- Record consent evidence: for each target/port interaction, note the `scripts/ctf_guard.py` command and outcome (or the deliberate `CTF_SKIP_GUARD=1` choice) alongside the relevant hypothesis.

## Start‑of‑Task Checklist
1. Minimal Block.
2. Hint‑to‑Action Checkpoint — capture any available mission text (`node.truth`, mission briefings, help banners) and translate it into a checklist before the first probe.
3. Initial 3–7 step plan (ranked by expected signal).
4. Hypothesis Ledger with controls, null counters, decisions, and timeboxes.
5. Tool sanity check for required libraries (log failures + alternatives).

## Logging Standards
- Use Probe stanzas for steps that change the hypothesis picture. Consolidate supporting micro-commands into a Quick Probe Bundle when they target the same discriminator instead of emitting a new probe per shell line. `scripts/log_probe.py` now appends a markdown summary to `notes.md` automatically; rely on it so probes are always visible in the primary log.
- Record Rules consulted for traceability.
- After two null probes, reassess the plan before continuing.
- When a hint-bearing command runs, quote the essential line, note the derived checklist in the probe, and mark when each item is executed.
- Store only decisive evidence excerpts under `artifacts/`. If the response merely confirms “no signal” or repeats a banner, capture an inline quote in `notes.md` and discard the file. Creating a file is justified only when the content will be cited or diffed later; do not attach every request/response just to satisfy the evidence field.
- Prefer piping command output directly to the console (`head`, `jq`, etc.); create scratch files only when you need to diff, parse, or cite the full response later, and purge them once the excerpt is logged.
- Maintain a lightweight `tmp/` or `/tmp` scratch area for the rare transient data that truly needs a file and wipe it once the decisive artifact is captured.
- Log hypothesis pivots, null counters, and timebox expirations explicitly.
- When scripts under `scripts/` or third-party helpers under `tools/` are executed, capture the command, purpose, checksum (when relevant), manifest hash, and resulting artifact path. If a helper is missing or outdated, document the fallback action and flag the follow-up in Pivot & Timebox Notes.
- Optional helpers: `scripts/log_probe.py` can append probe summaries to `notes.md` if it saves time, but manual logging is fine. Skip checksum utilities unless the brief explicitly requests one.
- Close every mission with an updated `report.md`; the writeup is no longer optional.

## Reference Harness
- Mirror provided primitives rather than approximating them; import official helpers whenever available.
- Reproduce transcripts/known plaintext locally to confirm harness equivalence before attacking secrets.
- Maintain short sanity tests (round‑trip, checksums) alongside solvers; rerun after major pivots.


## Good vs Bad logging (examples)

**Good (bundle):**
```
Probe 3: Login flow oracle (H2)
Checks:
  - `POST /login (valid)` → 302 to /dashboard
  - `POST /login (invalid)` → 200 + "Invalid password"
Evidence: artifacts/h2_p3.txt (diff of headers)
Interpretation: oracle present → proceed to session fixation
Decision: continue
Rules consulted: rules/category-heuristics.md#Web
```
**Bad (noisy):**
- Separate probes for each curl call, each saved as a full response artifact.
