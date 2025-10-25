# Scripts Toolkit

Helper scripts intended for autonomous CTF workflows.

- `ctf_guard.py` — enforce consent gate (`CTF_ALLOWED`, `targets.allow` with wildcard `*`, optional `CTF_SKIP_GUARD`).
- `bootstrap_environment.sh` — capture environment snapshot and prepare workspace directories.
- `ensure_wordlists.sh` — (on-demand) fetch or decompress canonical password lists.
- `fetch_linpeas.sh` — (on-demand) download the latest `linpeas.sh` into `tools/`.
- `socat_forward.sh` — lightweight wrapper for local→internal port forwarding.
- `log_probe.py` — append structured probe JSONL records under `artifacts/`.
- `jenkins_reverse_shell.groovy` — script-console ready reverse shell template.
- `sync_toolkit.sh` — mirror curated helpers from `toolkit/` to
  `${TOOLKIT_ROOT:-~/ctf_toolkit/standard}` when you need a curated cache.

Each script prints the artifact path or action taken; log executions in `notes.md` when you invoke them. Run `ctf_guard.py` before any non-trivial interaction with a target (or set `CTF_SKIP_GUARD=1` explicitly to bypass).
