# Category Heuristics (v2)

Use these ladders to design smallest decisive probes. Before firing heavy enumeration, read this file and record `Rules consulted` inside your probe stanza.

## Reverse Engineering / PWN
- Confirm reachability and IO contract first. Run `file`, `checksec` to note NX/PIE/RELRO/FORTIFY, seccomp.
- Exploit ladder: ret2reg (jmp/call register already under control) → ret2win (existing success function) → ret2plt/libc → minimal ROP (2–4 gadgets). Prefer reuse of register state from recent syscalls (`read`, `write`).
- Extract constants/tables early (`file`, `strings -a`, `objdump -D -M intel`). For crackmes, map compare primitive and implement a harness mirroring width/endianness exactly.
- When challenge drops you into an assembler-to-shellcode pipeline, inventory available directives—`incbin`, macro includes, or literal binary emitters often let you read flag files directly without entering traditional shellcode.
- Gadget hunt is mandatory before complex payloads; cache results in `artifacts/`.
- Founder consoles and similar interfaces routinely reject malformed payloads with repeatable `[DENIED]` messages—treat these as format bugs, revisit hint transcripts, and apply the instructed transform (ordering, hashing, encoding) before hunting new capabilities.
- When NPC or helper nodes spell out fragment order or digest requirements, mirror the algorithm exactly (concatenate, hash, trim, etc.) and capture the intermediate string/hash in artifacts for reuse.
- If spawned shell immediately exits or stays silent, pivot to command-style payloads (`system("cat flag")`, `execve` with `dup2`) so exploit still exfiltrates the target without relying on interactivity.
- On glibc ≥ 2.28 FSOP targets (stdout abuse, "no overflow" hints), prioritize `_wide_data->_wide_vtable` paths and `_IO_wfile_overflow` instead of forging main vtable (guarded by `_IO_vtable_check`).
- If arithmetic/character filters exist (e.g., `xor_eq`, `bitand` only), map permitted operators and build a minimal DSL: derive constants via `sizeof`, powers-of-two multiplications, bitwise assembly, and pointer reuse to reach stack/libc offsets.
- Track discovered gadget offsets and pointer chains explicitly; reapply them rather than brute-forcing anew after failures.
- If stdout/input is blocked but process exit status returns, use repeated `exit()` invocations to leak bytes (e.g., convert characters to status codes) before pursuing heavier ROP.
- Even on modern compilers, legacy storage qualifiers (`register`, etc.) can zero caller-saved registers cheaply—prime them to satisfy one-gadget constraints instead of scripting bespoke init chains.
- If binary targets different OS/architecture or depends on unavailable libraries, assume zero live execution. Use disassembly/IR dumps to recover constants and algorithms, and reproduce validation logic in a helper script instead of expecting executable to run locally.
- When ptrace or debuggers are blocked, try lightweight instrumentation first: LD_PRELOAD hooks on libc I/O plus inspection of callee-saved registers often expose validation state without recreating the whole VM.
- If a verifier combines per-character checks with a final digest, use character oracle to recover prefix and reserve brute-force (or targeted search) for remaining digest-constrained suffix.

## Esolang / Multi-stage Compilers
- Map execution pipeline (source → compiler → interpreter/runtime) immediately; compile a toy program to capture each intermediate artifact and stash them under `artifacts/` for diffing.
- Read code generator for pointer arithmetic rules and sentinels. Signed/unsigned mistakes or missing lower-bound checks often let tape pointer wander negative and corrupt host memory.
- Hunt for constructs that emit raw interpreter primitives with minimal scaffolding (e.g., `char` over `byte` to print one cell, headers that skip ASCII conversion); the smaller the emitted brainfuck, the easier it is to steer unbounded pointer increments toward saved return addresses or canaries.
- Reverse allocation policy: note how variables/functions place cells on tape or stack so you can line up helpers (macro functions, bulk allocators) that give precise pointer positioning during exploitation.
- Treat restricted alphabets or missing digits as constraint system. Prebuild constant-generation gadgets (increment loops, assignment chains) so payloads stay readable and adaptable.
- For polyglot toolchains, catalogue comment/statement separators per language; carve disjoint regions so each runtime sees only its intended payload before implementing shared templates (e.g., printf shims) for self-reference.
- Confirm interpreter semantics (cell width, wraparound, pointer bounds) by reading its source or running probes; assumptions baked into exploit must match deployed binary.

## Web / Renderer / HTML→PDF
- Fingerprint stack (headers, error pages, JS/CSS) before exploitation attempts.
- Run a focused fuzz pass (`ffuf`, `feroxbuster`, `gobuster`) immediately after fingerprinting when hidden routes or parameter discovery would materially change the plan. Seed the wordlist with on-site terminology first, cap scope, and log the signal (404/200 patterns) before expanding.
- Test basic access control/IDOR/misconfig first; escalate to SSRF/SSTI/upload only with evidence.
- Treat “already registered/invalid” banners as hypotheses, not facts—validate the backend decision by replaying with alternate encodings (Unicode, casefold, padding) and inspecting what the application actually stores or reflects.
- When the service copies your input into a scaffold (git apply, template sync), inspect the resulting tree immediately—seeded modules (`enum`, `decimal`, CLI wrappers) often retain direct `__builtins__`/`sys.modules` handles you can promote instead of brute-forcing the jail.
- Enumerate exposed navigation links or listings (e.g., members, staff pages, changelogs) immediately to collect valid identities, roles, or other context for targeted probes.
- Harvest stored artefacts whenever uploads land in a readable bucket/directory; leftover files often leak bypass patterns, payload names, or expected directory structure.
- Valid/invalid oracle: when form processes untrusted content, send one clearly valid payload and one clearly invalid payload to learn how interface signals success vs failure. Treat any deterministic difference (status code, message, body fragment) as an oracle before exploring other routes, and immediately probe with `'`/`"`/`OR 1=1` style tests to rule in or out SQL injection.
- When an oracle sits on a numeric selector (enums, frequency pickers, etc.), assume SQLi first: try a boolean payload (`value=0' AND 1=1--`) and, on success, identify the back-end (error strings, `sqlite_version()` check) before burning time on auxiliary surfaces.
- For SQLite targets, jump straight to `load_extension` feasibility checks once SQLi is confirmed; if uploads exist, prepare a minimal shared object that copies the target file into a readable location.
- Session analysis: when authentication relies on cookies or bearer tokens, capture and decode session state before first login, right after successful login, and again after deliberately failed attempt while reusing same cookie jar. Comparing these snapshots quickly surfaces session fixation, incomplete resets, or privilege escalation hints.
- If failed login leaves identity data or privilege flags intact, immediately try accessing privileged routes with that same session (and log explicit negative control) before escalating to brute-force attacks.
- Markdown/WYSIWYG previews – run fixed mini-suite before pivoting:
  - Mirrored plain text vs HTML (`bold`, `<b>bold</b>`) to confirm renderer and escaping rules.
  - File include syntaxes and media fetches: `--8<-- "./README"`, `{! ./README !}`, `![probe](/etc/hosts)`, `![probe](/proc/self/environ)`, `[link](/app/flag.txt)`.
  - Observe returned HTML even if it arrives inside JSON; stash it and open in browser when external loads are plausible.
  - If suite fails but response hints at Markdown, search docs/blogs for renderer-specific tricks before abandoning vector.
- If cookies or parameters carry PHP serialized blobs, decode them on sight and test type-juggling primitives (`b:1`, `b:0`, `s:0:""`, `i:0`) before investing in credential brute force; loose `==` checks against stored hashes are common.
- Renderer SSRF: prefer controlled redirectors (`httpbingo`) before custom infra; attempt benign local-file reads (`/etc/hosts`).
- Differentiate template evaluation vs placeholder substitution; use math probes before engine-specific payloads.
- When case transformations matter (e.g., login normalization), test Unicode homoglyphs and compare `.lower()` vs `.casefold()` behaviour locally to predict duplicates. Keep the automated check small: verify how the backend canonicalises and whether the transformed value is used for comparisons.
- Keep wordlists curated and justified; note encoding or normalization strategies only when indicated (see `rules/wordlists.md`).
- CMS footholds (WordPress, Joomla): hunt for hidden paths (`/wp-admin`, `/wp-content/themes/`, installers) with `ffuf` before brute force. Compare login error responses to confirm valid usernames, then launch targeted password sprays using high-signal lists (`rockyou`) via captured HTTP templates—log the discriminator evidence before expanding scope.
- Once administrator access is obtained, prefer code execution vectors that you can trigger deterministically (theme editor 404 template, plugin uploader). Stage reverse shells via known-good payloads (`msfvenom`, PHP one-liners) and remember to cite the exact request/file edited.
- For Jenkins/CI portals discovered via pivot, test anonymous script consoles first. If authentication gates exist, prioritize Metasploit or `hydra` modules tuned for Jenkins (with `rockyou`) after confirming account presence. Groovy reverse shell templates live in `scripts/jenkins_reverse_shell.groovy`—tailor host/port only.
- Maintain ready-to-use exploit templates (XXE, SSRF, SSTI) and a short list of reliable raw-hosting endpoints so payload delivery pivots quickly if service blocks requests.
- Under severe alphabet or length budgets, treat the interaction as multi-stage: first commit a minimal patch to widen files or stash helpers, then trigger the true payload in the expanded space.
- For GraphQL SPAs: quickly pull down bundles, capture `baseURL`, authenticate to obtain valid JWT, and only then run introspection or mutations.
- Quick standard payloads worth firing early when names or hints reference "patch", "diff", or "template":
  - JSON Patch array: `--data-raw '[{"op":"test","path":"/"}]'`
  - JSON Merge Patch: `--data-raw '{"probe":"value"}'` with `Content-Type: application/merge-patch+json`
  - Multipart skeleton upload (empty file + metadata)
  - Toggle between `-d`, `--data-raw`, and `--data-binary` to detect parsers sensitive to encoding
  - Minimal GraphQL introspection query
  - Capture and log response snippet for each to inform next hypothesis.
- Suspect PHP path truncation when `.php` extensions are auto-appended; script a filler generator that pads `a/../target` with `/.'` pairs up to 4096 characters so suffix is dropped after normalization.
- If SSRF reaches Redis without authentication, jump straight to gopher/RESP payloads; favor proven `CONFIG SET dir /root/.ssh` + `dbfilename authorized_keys` flow to drop your public key and avoid slower cron/RDB tricks.

## GraphQL APIs
- Default to introspection or reuse queries found in frontend bundles to map schema fast.
- Treat GraphQL args as raw backend inputs: try both well‑formed values and lightweight injections; note backend error echoes.
- Combine aliases/fragments to minimize noise and watch for auth gaps in resolver responses.

## Privilege Escalation / Host Recon
- Always capture and stash an automated enumeration run (`tools/linpeas.sh`, `lse.sh`, winPEAS) before manual digging; cite hash/path for reproducibility.
- Check `/opt`, `/srv`, and home directories for saved credentials, deployment notes, and internal service mentions prior to running heavy scanners.
- Track internal-only services surfaced in loot (Docker bridge IPs, 127.0.0.1 ports). Prepare port forwards via `scripts/socat_forward.sh` or SSH tunnels and document the mapping inline with the hypothesis pursuing it.
- When inside containers, rerun the enumeration helper to map mount points and host credentials. Treat container breakout clues (nfs mounts, docker.sock, plaintext notes) as separate hypotheses instead of folding them into generic privilege escalation.
- Refresh the hypothesis ledger after each privilege jump: new user means new controls, new flag locations, and potentially different safety assumptions.

## SQL Injection / Database Extraction
- Identify the database engine early via errors, banners, or limiting probes; match payloads accordingly.
- Use arithmetic perturbations to elicit verbose errors and confirm injection.
- Binary search `ORDER BY n` and `UNION SELECT` column counts to match query shape.
- Leverage catalog tables to enumerate schema; prefer `CHAR()`/`hex()` when quotes are blocked.
- When quotes are filtered but commas/parentheses pass, try extending INSERT `VALUES` to append a controlled row.
- Use aggregates (`group_concat`, `string_agg`) or pagination for efficient exfil.
- Terminate injected clauses cleanly when backend expects trailing syntax.
- Cache proven payload skeletons in `scripts/` for reuse.
- Probe for truncation collisions and storage normalization issues.
- Exploit routed queries by replacing seed values with downstream clauses when applicable.
- Obfuscate under keyword filters: hex‑encode, comment splits, boolean arithmetic.

## Crypto / Checksums
- Start by sketching the exact construction: block size, rate/capacity split, padding/length injection, and truncation. Hash trivial messages (empty, one-byte, rate−1, rate, rate+1) to confirm the model before attempting exploitation.
- Document invariants (e.g., rotation counts, S-box symmetries, modular base) and identify which portions of the state are exposed/hidden. Use these invariants to craft hypotheses rather than “guess & brute-force”.
- Classify primitive (RSA, stream/PRNG, hash misuse, lattice) and pick the standard playbook.
- Match arithmetic domain exactly; confirm quick round‑trips before assuming XOR semantics.
- Pull trusted helpers (Sage, PARI/GP, gmpy2) before writing custom math.
- Maintain crib sheets for PoW, RSA patterns (Wiener, Franklin–Reiter), lattice setups.
- Cache reproducible tooling for Boneh–Durfee/Coppersmith (e.g., `boneh_durfee.sage`); when inverse `d` or partial `p+q` leaks appear, compute a φ estimate via continued fractions before attempting heavier searches.
- Treat timings/lengths/errors as oracles; design minimal probes.
- Use range‑shrinking searches and hand tight bounds to solvers instead of blind brute force.
- Capture partial leaks and build constraints before full brute force.
- Keep an oracle‑query counter; pivot to analytic approach if info per query drops.

## Jailbreaks / Restricted Evaluators
- Map available syntax quickly; test earliest safe execution hooks.
- Rebuild forbidden tokens via encoding/concatenation; exploit import‑time side effects when permitted.
- Abuse lazy evaluation, representation hooks, and stderr when stdout is filtered.
- Prefer "safe" gadgets that yield interactivity (`code.interact`, `pdb.set_trace`) to bypass scanners.

## Social / Logistics / Meta
- Follow instructions literally; mirror out‑of‑band requirements in `notes.md`.
- Maintain a handout checklist to avoid missing embedded hints.
- Mirror public hints/team chatter and adapt before repeating failed approaches.

## Forensics / Stego / Misc
- Validate magic vs extension; collect metadata (`exiftool`, `pdfinfo`, `binwalk`).
- Follow bytes↔hex↔base64↔URL ladder; stop at first meaningful text.
- Use vendor tools for serialized objects; prefer reproducible offline replay.
- ZipCrypto: fingerprint with `zipinfo -v`; use known‑plaintext attacks before brute force.
- Record decisive offsets for known plaintext; avoid near‑miss churn.
- Scan for zero‑width/invisible characters when text looks odd.
- Extract embedded disk images or ADS streams when sizes look suspicious.
- For enterprise telemetry, prefer vendors' parsers first; then grep for likely flag patterns.
- Guard recursive searches with file size limits or directory scopes.
- Use modern barcode decoders before manual reconstruction.

## Cryptography (Minimal Reminders)
- Fingerprint quickly; keep Sage handy; log versions and notebooks/scripts for reproducibility.

## Cloud / AD (Minimal)
- Metadata SSRF targets; object storage basics; token hygiene; AD footholds and logging throttles.
