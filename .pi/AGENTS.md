# AGENTS.md — `.pi` maintenance notes (dotfiles repo)

These notes are for maintaining this dotfiles repo. Keep this file at `~/.pi/AGENTS.md`.

## Layout policy

- Keep Pi-native runtime/config under `~/.pi/agent`:
  - `settings.json`, `modes.json`, `keybindings.json`
  - `extensions/`, `skills/`
  - runtime files like `sessions/`, `auth.json`
- Keep dotfiles-owned support assets under `~/.pi`:
  - `~/.pi/shims/`
  - `~/.pi/licenses/`
  - `~/.pi/README.md`, `~/.pi/AGENTS.md`

## Important guardrail

Do **not** set `PI_CODING_AGENT_DIR=~/.pi`.

Keep Pi on its default agent dir (`~/.pi/agent`) so runtime semantics stay Pi-native.

## Provenance/licensing

- Keep attribution headers/comments in copied third-party files.
- Keep third-party licenses under `~/.pi/licenses/<source>/`.

## Shim naming

Use explicit names:

- `skill-*` for skill helpers
- `extension-*` for extension helpers
