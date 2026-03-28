# AGENTS.md: notes for maintaining `~/.pi` in dotfiles

This file applies only to repo-managed `~/.pi/**`.

Read `~/.pi/README.md` first for layout/context.

## Package strategy (flexible)

- `~/agent-skills` is the main curated package for local forks and custom tweaks.
- It is also valid to install/use third-party packages directly when local changes are not needed.
- Do not insist on folding every package into `~/agent-skills`; follow user preference per task.

## Short-lived experiments

- Temporary experiments may live in `~/.pi/agent/extensions` or `~/.pi/agent/skills`.
- Stable experiments can either be folded into `~/agent-skills` **or** kept as direct package dependencies.

## Local scripts and shims

- If a skill/extension invokes a local script (e.g. `*.py`), use a shim so transcripts stay readable.
- If a shim appears missing, call it out.
- Shim naming:
  - `skill-*` for skill helpers
  - `extension-*` for extension helpers
