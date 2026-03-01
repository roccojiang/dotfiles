# AGENTS.md — `.pi` maintenance policy (dotfiles repo)

This file governs repo-managed `~/.pi/**` content only.

## Scope and placement

- Keep this policy in `~/.pi/AGENTS.md`.
- Do **not** duplicate it in `~/.pi/agent/AGENTS.md` (avoid affecting global Pi runtime context unexpectedly).

## Layout policy

- Keep Pi-native runtime/config under `~/.pi/agent`:
  - `settings.json`, `modes.json`, `keybindings.json`
  - runtime files like `sessions/`, `auth.json`
  - `extensions/`, `skills/` only for short-lived local experiments
- Keep dotfiles-owned maintained assets under `~/.pi`:
  - `~/.pi/packages/` (all maintained forked/upstream-mirrored and first-party Pi packages)
  - `~/.pi/shims/`
  - `~/.pi/README.md`, `~/.pi/AGENTS.md`

Prefer loading maintained extensions/skills through `~/.pi/agent/settings.json` `packages` entries pointing to `../packages/...`.

## Important guardrail

Do **not** set `PI_CODING_AGENT_DIR=~/.pi`.

Use Pi’s default runtime directory (`~/.pi/agent`) to preserve expected semantics.

## Provenance and licensing

- Keep attribution headers/comments in adapted third-party files.
- Keep upstream `LICENSE`/`NOTICE` files within each package under `~/.pi/packages/<source>/`.

## Shim naming

- `skill-*` for skill helpers
- `extension-*` for extension helpers
