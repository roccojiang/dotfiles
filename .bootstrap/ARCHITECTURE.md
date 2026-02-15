# Bootstrap Architecture: Bash Orchestrator + Step-Owned Domain Logic

This document describes the bootstrap design used by `./install.sh`.

## Goals

- Keep orchestration dependency-light (Bash only).
- Keep user flow explicit and transparent.
- Make each step independently runnable and easy to inspect.
- Keep domain behavior colocated with the step that owns it.
- Preserve idempotency and safe re-runs.
- Produce clear logs and summaries.

## Repository Layout

```text
install.sh
.bootstrap/
  lib/
    ui.bash
    cli.bash
    runner.bash
  steps/
    10-homebrew.bash
    20-fish-install.bash
    30-default-shell.bash
    40-fish-config.fish
    50-pi-agent.bash
```

Design rule:
- `lib/` is for meta-level shared orchestration helpers.
- Domain logic lives in `steps/*`.

## Execution Model

- `install.sh` is the top-level orchestrator.
- It validates and sources `lib/*` helpers, parses flags, and discovers steps from `./.bootstrap/steps`.
- Step files are the source of truth for display name, policy, grouping, prompts, and optional requirements.
- Steps execute in child processes (`bash`/`fish`) via `runner.bash`.
- Output is streamed to terminal and appended to a timestamped log file.

## Step File Format (Required Metadata Header)

Each executable step file must include metadata comments near the top of the file.

Expected keys:

- `STEP_NAME` (required): human-readable name shown in output/summary
- `STEP_GROUP` (optional, default `default`): used by CLI skip flags
- `STEP_POLICY` (optional, default `soft`): `soft` or `hard`
- `STEP_PROMPT_BEFORE` (optional, default `1`): `1` prompts before execution, `0` runs directly
- `STEP_REQUIRES_COMMAND` (optional): if command is missing, step is skipped with reason
- `STEP_POST_ACTION` (optional): install-level post-step hook (currently `load_brew_env`)

Example:

```bash
#!/usr/bin/env bash
# STEP_NAME="Homebrew"
# STEP_GROUP="homebrew"
# STEP_POLICY="soft"
# STEP_PROMPT_BEFORE="1"
# STEP_POST_ACTION="load_brew_env"
set -euo pipefail
```

```fish
#!/usr/bin/env fish
# STEP_NAME="Bootstrap fish plugins/prompt"
# STEP_GROUP="shell"
# STEP_POLICY="soft"
# STEP_PROMPT_BEFORE="1"
# STEP_REQUIRES_COMMAND="fish"
```

### Parsing rules

- Metadata is read from `# KEY="value"` comment lines.
- Unknown keys are ignored.
- Invalid `STEP_POLICY` falls back to `soft` with warning.
- Invalid `STEP_PROMPT_BEFORE` falls back to `1` with warning.

## Step Discovery, Ordering, and Group Semantics

- Steps are discovered by scanning `./.bootstrap/steps` for `*.bash` and `*.fish` files.
- Execution order is lexical sort of filenames (use numeric prefixes like `10-`, `20-`, ...).
- Progress labels (`Step X/Y`) are derived from discovered step count and run index.
- Current groups mapped to CLI flags:
  - `homebrew` ↔ `--skip-homebrew`
  - `shell` ↔ `--skip-shell`
  - `pi-agent` ↔ `--skip-pi-agent`

For new groups, add matching skip-policy handling in `install.sh` if needed.

## Runner Contract

Every step must follow this status code contract:

- `0` success
- `10` skipped/no-op
- any other non-zero failure

Runner policies per step:

- `soft`: report failure, continue bootstrap
- `hard`: report failure, abort remaining steps

## UX Principles

Each step should clearly show:

1. Step name (with `Step X/Y` progress)
2. Optional confirmation prompt
3. Live command output
4. Final outcome (completed/skipped/failed)

Non-interactive behavior:

- `--yes` auto-confirms prompts
- non-TTY mode auto-confirms prompts
- `NO_COLOR` disables color formatting

Prompt behavior:

- prompt format is `[Y/n]`
- pressing Enter defaults to `Y`

## Additional Architectural Decisions

- **Step files are authoritative** for step metadata. Avoid duplicating step definitions in `install.sh`.
- **`lib/` stays meta-only** (UI, CLI parsing, runner mechanics), while domain behavior remains in steps.
- **Child-shell color output is preserved** for step scripts by setting `PI_BOOTSTRAP_FORCE_COLOR=1` when spawning step processes.
- **Parent-shell environment refresh** is explicit and post-step (for example Homebrew shellenv), since child-shell exports do not propagate upward.
- **Summary entries include progress labels** so users can map outcomes back to the exact step index shown during execution.

## Idempotency Rules

Steps must be safe to re-run:

- detect already-satisfied state
- avoid blind overwrite
- backup replaced files where appropriate
- return `10` for no-op/skipped conditions

## Error Handling and Policies in This Repo

Current step policy intent:

- Homebrew: soft-fail
- fish install: soft-fail
- default shell (`chsh`): soft-fail (print manual remediation)
- fish plugin/prompt bootstrap: soft-fail
- pi-agent symlink bootstrap: hard-fail

## Logging

Logs are written per run under:

```text
~/.local/state/dotfiles-install/install-YYYYmmdd-HHMMSS.log
```

The log path is printed at startup and in the final summary.

## Notes on Shell Environment Propagation

Because steps run in child shells, exported environment changes do not automatically affect the parent `install.sh` process.

For Homebrew specifically, the parent orchestrator refreshes `brew shellenv` after the Homebrew step so downstream steps can rely on updated `PATH`/`HOMEBREW_*` values in the same run.
