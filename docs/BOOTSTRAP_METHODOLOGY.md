# Bootstrap Methodology: Bash-Orchestrated Wizard with Multi-Language Steps

This document describes a maintainable bootstrap strategy for dotfiles setup that keeps dependencies minimal while preserving transparency and user choice.

## Goals

- Keep bootstrap dependency-light (only Bash required at orchestration layer).
- Provide a simple wizard-like CLI flow (not a full TUI).
- Keep each step explicit, observable, and skippable.
- Support calling scripts in multiple languages (Bash, Fish, Python, etc.).
- Preserve idempotency and safe re-runs.
- Log everything clearly for audit/debugging.

## Core Approach

Use a **Bash orchestrator** as the single entrypoint (`./install.sh`) and split implementation into modular step scripts.

- `install.sh` handles interaction, flow control, confirmation prompts, and reporting.
- Step scripts do the actual work and may be written in any language.
- A common execution wrapper ensures consistent output, logging, and status handling.

This gives the usability of a wizard without introducing Python/Rust/Go dependencies for the control plane.

---

## Repository Structure

Suggested layout:

```text
install.sh                 # thin top-level shim/orchestrator
.bootstrap/
  lib/
    ui.bash           # colours, prompt helpers, status printing
    runner.bash       # run_step wrapper, logging, command execution
    system.bash       # OS/hostname helpers
  steps/
    10-homebrew.bash
    20-shell.bash
    30-fish.fish
    40-pi-agent.bash
    50-optional-python.py
```

Notes:
- Numbered step files are optional but help define order.
- Keep `install.sh` thin and declarative (step list + prompts).
- Prefer one responsibility per step script.

---

## Transparency Model

Every step should visibly show:

1. **What** is about to run.
2. **Why** it matters.
3. **Whether** user wants to proceed (`y/n`).
4. **Live output** while running.
5. **Outcome** (`success` / `skipped` / `failed`).
6. **Next action** if manual follow-up is required.

### Standard execution wrapper

All commands/scripts should go through a single wrapper function (`run_step`) that:

- prints step header
- optionally prompts for confirmation
- streams output to terminal (`tee`) and log file
- captures true exit status
- maps statuses to a uniform result model

This keeps behaviour consistent even when invoking Fish/Python scripts.

---

## Status Code Contract

Define and document a shared contract for all step scripts:

- `0` = success (change made or already OK)
- `10` = skipped/no-op (intentional skip or already satisfied)
- any other non-zero = failure

This makes cross-language integration predictable.

---

## Multi-Language Integration

The Bash orchestrator can call other languages directly.

Examples:

```bash
fish .bootstrap/steps/30-fish.fish
python3 .bootstrap/steps/50-optional-python.py
```

### Capturing output and status safely

Use pipefail and PIPESTATUS to preserve the original exit code when piping through `tee`:

```bash
set -o pipefail
some_command 2>&1 | tee -a "$LOG_FILE"
status=${PIPESTATUS[0]}
```

This enables live output + persistent logs + reliable error handling.

---

## UX Guidelines

Keep UI intentionally simple:

- colour-coded lines (`INFO`, `WARN`, `ERROR`, `OK`)
- `y/n` prompts with sensible defaults
- concise summaries per step
- final summary block with:
  - completed steps
  - skipped steps
  - failed steps
  - manual commands to run next

Respect non-interactive environments:

- `--yes` to auto-confirm prompts
- `NO_COLOR` support
- gracefully degrade when not in TTY

---

## Idempotency Rules

Every step should be safe to rerun:

- detect existing installs/config before changing anything
- avoid blind overwrites
- backup/rename existing files when replacing
- print why a step is skipped

This is essential for long-term maintainability and trust.

---

## Error Handling Policy

Use explicit step policies:

- **hard-fail steps**: required prerequisites (e.g. critical directory bootstrap)
- **soft-fail steps**: convenience operations (e.g. `chsh`)

Example soft-fail behaviour for `chsh`:
- do not abort full install
- print clear warning and manual command(s)

---

## Logging Strategy

Write all command output to a timestamped log file, e.g.:

```text
~/.local/state/dotfiles-install/install-YYYYmmdd-HHMMSS.log
```

At end of run, print path to log file.

---

## Example `install.sh` Flow (Conceptual)

1. Initialise shell safety flags and logging.
2. Load helper libs (`ui.bash`, `runner.bash`, etc.).
3. Print detected environment (OS, host, user).
4. For each step:
   - explain step
   - ask `Proceed? [Y/n]`
   - run via `run_step`
5. Print final summary + manual follow-ups.

---

## Why This Approach

- Keeps bootstrap understandable and transparent.
- Avoids introducing runtime dependencies just for orchestration.
- Supports richer implementation languages where useful.
- Stays close to common dotfiles ecosystem patterns.
- Easy to evolve later (if needed) into Python/Go/Rust orchestrator.

---

## Future Evolution (Optional)

If complexity grows (stateful flows, more branching, richer prompt logic), consider migrating only the orchestrator to Python while keeping step scripts and contracts unchanged.

Because step execution is already standardised, this migration becomes mechanical rather than architectural.

## TODO

- Add a lightweight bootstrap smoke-test script and run it in CI / before release (at minimum: `--help`, all-skip run, and `--pi-agent-only --yes` safety path).
