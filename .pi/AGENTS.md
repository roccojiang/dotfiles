# AGENTS.md: notes for maintaining `~/.pi` in dotfiles

This file applies only to repo-managed `~/.pi/**`.

Read `~/.pi/README.md` first for layout/context and vendoring workflow (`./bin/vendor-sync`, `.vendor/config.toml`, `.vendor/lock.toml`).

## Maintained packages

- For maintained extensions/skills, load via `~/.pi/agent/settings.json` `packages` entries
  (local paths like `../packages/...`).

## Short-lived experiments

- Temporary experiments may live in `~/.pi/agent/extensions` or `~/.pi/agent/skills`.
- Once stable, consolidate them into a package under `~/.pi/packages`.

## Local scripts and shims

- If a skill or extension invokes a local script (e.g. `*.py`), a shim should be used so
  transcripts stay readable. If it looks like a shim was forgotten, call it out to remind the user.
- When naming shims, use explicit prefixes:
  - `skill-*` for skill helpers
  - `extension-*` for extension helpers
