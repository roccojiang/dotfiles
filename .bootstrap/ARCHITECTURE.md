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
- It validates and sources `lib/*` helpers, parses flags, and runs ordered steps.
- Steps execute in child processes (`bash`/`fish`) via `runner.bash`.
- Output is streamed to terminal and appended to a timestamped log file.

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

1. Step name
2. Optional confirmation prompt
3. Live command output
4. Final outcome (completed/skipped/failed)

Non-interactive behavior:

- `--yes` auto-confirms prompts
- non-TTY mode auto-confirms prompts
- `NO_COLOR` disables color formatting

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
