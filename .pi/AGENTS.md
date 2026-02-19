# AGENTS.md — `.pi` maintenance policy (dotfiles repo)

This file governs repo-managed `~/.pi/**` content only.

## Scope and placement

- Keep this policy in `~/.pi/AGENTS.md`.
- Do **not** duplicate it in `~/.pi/agent/AGENTS.md` (avoid affecting global Pi runtime context unexpectedly).

## Layout policy

- Keep Pi-native runtime/config in `~/.pi/agent/` (for example `settings.json`, `modes.json`, `keybindings.json`, `extensions/`, `skills/`, `sessions/`, `auth.json`).
- Keep dotfiles-owned support assets in `~/.pi/` (for example `shims/`, `licenses/`, `README.md`, this `AGENTS.md`).

## Guardrail

Do **not** set `PI_CODING_AGENT_DIR=~/.pi`.

Use Pi’s default runtime directory (`~/.pi/agent`) to preserve expected semantics.

## Provenance and licensing

- Preserve attribution headers/comments in copied third-party files.
- Store third-party licenses under `~/.pi/licenses/<source>/`.
- Keep the current copied-file inventory/provenance summary in `~/.pi/README.md`.

## Shim naming

- `skill-*` for skill helpers
- `extension-*` for extension helpers
