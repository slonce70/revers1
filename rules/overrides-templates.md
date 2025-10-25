# AGENTS.override.md — Templates (CTF)

## Web (override)
```
# Web CTF — override
## Goal
Exploit with smallest decisive probes; evidence before heavy enumeration.
## Fast checks
- Fingerprint stack; run IDOR/misconfig sanity; decode sessions.
- Run the Markdown/WYSIWYG mini-suite before SSTI/uploads.
## Safety
Read-only by default; throttle on identical 5xx repeats.
## Log discipline
Use Quick Probe Bundles; record Rules consulted: rules/category-heuristics.md#Web, rules/workflow.md#Stall-&-Pivot.
```
## PWN (override)
```
# PWN CTF — override
## Goal
Reach success path with minimal gadgets (ret2win/ret2plt/libc before full ROP).
## Fast checks
- `file`, `checksec`, `strings -a`; find easy win (ret2win) first.
## Safety
Sandbox when running untrusted binaries; prefer offline RE when unsure.
## Log discipline
Probe stanzas with decisive diffs only; artifacts: h<id>_p<n>.*
Rules consulted: rules/category-heuristics.md#Reverse-Engineering-/-PWN
```
## Crypto (override)
```
# Crypto CTF — override
## Goal
Classify primitive and design analytic attack before brute force.
## Fast checks
- Fingerprint primitive; try standard ladders (Wiener, small d, Coppersmith).
## Safety
Keep secrets redacted; store only decisive math derivations.
## Log discipline
Log solver inputs/outputs as single artifact; keep bounds/timings in notes.
Rules consulted: rules/category-heuristics.md#Crypto-/-Checksums
```
