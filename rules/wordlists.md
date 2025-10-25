# Wordlist & Credential Policy (v1)

Intent: constrain automated credential attacks to disciplined, challenge-driven probes that respect lab scope and rate expectations.

## Consent & Preconditions
- Run the Consent Gate (`scripts/ctf_guard.py`) before any password spraying or brute-force activity; block if the target/port lacks explicit approval in `targets.allow` or if `CTF_ALLOWED` is unset (set `CTF_SKIP_GUARD=1` only when you intentionally bypass).
- Confirm discriminator behaviour first: send at least one known-invalid username and one known-valid username (or analogous payloads) to verify error responses differ. Skip wordlists entirely when the interface does not leak a usable oracle.
- Record approval evidence in `notes.md` (`Consent check:` section) including timestamp, target, and discriminator output.

## Candidate Generation Ladder
1. **Challenge-derived candidates** — harvest names, terms, dates, and hints from the target content (user listings, config files, blog posts). Build a short candidate list (<10) before touching public wordlists.
2. **Contextual expansions** — apply simple transforms (case flips, suffix digits, season+year) grounded in observed data. Document the rationale for each family.
3. **Public wordlists (rockyou, seclists)** — allowed only after steps 1–2 fail, the interface exposes a reliable oracle, and scope permits. Limit to curated subsets whenever possible (e.g., top 1000 instead of full corpus).

## Execution Discipline
- Enforce strict attempt caps per hypothesis (default: 200 attempts or 2 minutes, whichever comes first). Renew cap only with fresh evidence.
- Interleave positive and negative controls (e.g., invalid password after every 20 attempts) to catch lockouts or response drift.
- Log tooling configuration in the probe stanza (wordlist source, rate limit, discriminator evidence). Include the hash and size of any custom list stored under `wordlists/`.
- Stop immediately on first strong signal (status code change, redirect, banner). Confirm manually before continuing.

## Storage & Hygiene
- Place reusable lists in `wordlists/` and record provenance plus checksum in `notes.md`.
- Delete ad-hoc generated lists once no longer needed, keeping only decisive subsets as artifacts when they affected the outcome.
- Do not redistribute large third-party lists in the repository; fetch them on demand (e.g., with `scripts/ensure_wordlists.sh` or manual downloads) only when a hypothesis calls for them.

## Tooling Suggestions
- Prefer HTTP replay tools (`ffuf`, `hydra`, `medusa`) that can run through saved request templates to minimize mistakes.
- Use throttling (`-t` concurrency, request delay) aligned with challenge guidelines.
- Capture the decisive request/response pair as an artifact when a credential succeeds; mask secrets in public writeups.
