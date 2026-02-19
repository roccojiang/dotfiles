# `.pi` layout and provenance (dotfiles repo)

TODO: rewrite this AI slop lol

This README documents repo-managed `~/.pi/**` layout and provenance.

Operational guardrails and maintenance policy live in `~/.pi/AGENTS.md`.

## Layout

### Pi-native runtime/config (`~/.pi/agent/`)

Keep Pi-native runtime/config here:

- `settings.json`, `modes.json`, `keybindings.json`
- `extensions/`, `skills/`
- runtime/state files (usually not edited directly), e.g. `sessions/`, `auth.json`

### Dotfiles-owned support assets (`~/.pi/`)

Keep dotfiles-owned support assets here:

- `~/.pi/shims/`
- `~/.pi/licenses/`
- docs (`~/.pi/README.md`, `~/.pi/AGENTS.md`)

## Shim naming

Use explicit prefixes:

- `skill-*` for skill helpers
- `extension-*` for extension helpers

Current shim:

- `shims/skill-web-search` → `~/.pi/agent/skills/web-search/search.py`

## Provenance and licensing

Some extensions/skills were copied from [`pasky/pi-amplike`](https://github.com/pasky/pi-amplike), commit:

- `25ff804d0cbd5dbf71d9922ac8eb9f0023ce24cd`

Copied files include:

- `extensions/handoff.ts`
- `extensions/modes.ts`
- `extensions/session-query.ts`
- `skills/session-query/SKILL.md`
- `skills/web-search/{SKILL.md,search.py}`
- `skills/visit-webpage/{SKILL.md,visit.py}`

Local adaptations include preserved attribution headers/comments and shim command naming (`skill-web-search`).

License copy:

- `~/.pi/licenses/pi-amplike/LICENSE`
