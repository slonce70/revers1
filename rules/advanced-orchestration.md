# Advanced Orchestration (optional)

## Code Ledger (lightweight)
Keep a succinct change log when agents modify the workspace.
```
- Commit: <hash or "uncommitted">
- Files: <paths>
- Rationale: <1–2 lines>
- Side effects: <notes or n/a>
- Revert: <how to undo>
```
Store this in `notes.md` under a `## Code Ledger` heading if the session spans many pivots.

## Context Registry (optional index)
Maintain a short list of other knowledge files if present (ADR, design specs). Link them once to reduce chatter:
```
- rules/category-heuristics.md — exploit ladders
- rules/workflow.md — pivot discipline
```
