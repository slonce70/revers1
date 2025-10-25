# Conditional Modules (v2)

Load modules on demand and record Rules consulted inside each probe stanza.

## Rule Loader (always)
- Trigger: new surface appears or a stall occurs.
- Action: skim the relevant file(s) under `rules/` and note them in the probe stanza.

## Research Burst
- Trigger: stalled hypothesis, unfamiliar primitive, or evidence pointing to novel behaviour.
- Action: articulate the exact unknown as a question, craft 2–3 web search queries that blend the category with distinguishing traits (e.g., `"sponge hash" padding modulo 59`, `"length byte collision" sponge`, `"CTF" "prime modulus" hash`), and capture Question → URL → Insight in `notes.md`. Prefer sources that explain mechanisms or common exploits over copy-paste solutions.
- Record which query produced actionable insight before resuming probes.

## Hint Consolidation
- Trigger: textual hint channels (`node.truth`, `system.hint`, mission briefings, NPC dialogue) expose directives.
- Action: record the hint text in the probe notes, distill it into an ordered checklist, and execute each step before pivoting. Treat the unexecuted checklist as an open item blocking hypothesis closure.

## Category Gate (≤90s)
- Write the top three candidate categories with a quick discriminator for each.
- Execute discriminators in VoI order and record: `Chosen=<category>; Evidence=<artifact>; Rejected=<...>`.

## Tool Sanity
- Confirm specialized libraries (`pwntools`, `sage`, `gmpy2`, disassemblers) before you depend on them.
- Ensure `TOOLKIT_ROOT` is set (default `~/ctf_toolkit/standard`) so helpers can be located predictably.
- Log failures and planned workarounds.

## Toolkit Preflight
- Trigger: mission start or resume after long pause.
- Action: run `scripts/bootstrap_environment.sh` for the snapshot, then fetch additional helpers only when a hypothesis demands them (wordlists, privesc scripts, toolkit sync). Export `TOOLKIT_ROOT` if unset so curated helpers remain locatable, and log which assets you intentionally pulled.
- Record successful fetches and note any helpers that remain pending.

## Consent Gate
- Trigger: before any interaction with a new host or port.
- Action: `export CTF_ALLOWED=1` once (or set `CTF_SKIP_GUARD=1` to bypass intentionally), ensure the target/port is listed in `targets.allow` (`*` wildcard defaults to all), run `scripts/ctf_guard.py`, and log the consent evidence in `notes.md`.

## Credential Ops
- Trigger: authentication surface with differing failure banners or known/default accounts.
- Action: confirm usernames first (compare error responses, enumerate) before running targeted password fuzzing with curated lists (e.g., `rockyou`). Use request templates captured via Burp and replay via `ffuf`/`hydra`, logging discriminator evidence.
- Reference: rules/wordlists.md

## Port Forward & Pivot
- Trigger: discovered internal-only services (e.g., Jenkins on 127.0.0.1, container network).
- Action: deploy `socat` or SSH tunnels via `scripts/socat_forward.sh` to expose the service safely. Record listener/target mapping, update firewall notes, and tear down forwards once no longer required.

## Container / Context Re-entry
- Trigger: new shell/user/container obtained.
- Action: capture a fresh environment snapshot, rerun local enumeration helpers (e.g., `tools/linpeas.sh`), and refresh hypotheses accounting for the new scope. Treat each context as its own mission phase with explicit pivot logs.

## Handouts
- Unpack provided archives immediately. Read README/rules before live interaction with remote services.

## Deployment Triage
- Review Dockerfiles, compose manifests, entrypoints, and wrappers to map components and state storage hints.

## Known Shortcuts Sweep
- Test defaults and canonical footholds (admin/admin, `/admin`, obvious SSRF) before heavy enumeration.

## Endpoint Sweep
- After initial review, run light automated probes against curated endpoint lists to surface hidden roles or admin routes.

## Hypothesis Roster
- Keep 3–5 active hypotheses with controls, null counters, and a decision state.

## Minimal Probe Design
- Define a smallest confirming test with expected success criterion and a negative control.

## Timebox Discipline
- Assign defaults per category; renew only with justification recorded in the ledger.

## Kill/Stop Criteria
- Define success checks, rerun plans, and stall triggers ahead of time.

## LLM Discipline
- Self‑check assumptions and risks before probes; require evidence paths for claims; mark low‑confidence interpretations and seek a second probe.

## Toolkit Fallback
- Trigger: required helper missing, corrupted, or version-mismatched after sync attempt.
- Action: document the gap in `notes.md`, capture the intended helper name + expected path, and note the interim workaround (manual command, quick script). Queue the helper for regeneration or download after the session and mark the follow-up in the pivot notes.
