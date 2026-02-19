# Pi configuration in dotfiles

This repo tracks Pi configuration in a split layout:

## Runtime/config (Pi-native)

These stay under `~/.pi/agent` because Pi expects them there:

- `settings.json`, `modes.json`, `keybindings.json`
- `extensions/`, `skills/`
- runtime/state files (not typically edited here), e.g. `sessions/`, `auth.json`

## Dotfiles-owned support assets

These live one level up under `~/.pi`:

- `~/.pi/shims/`
- `~/.pi/licenses/`
- docs (`~/.pi/README.md`, `~/.pi/AGENTS.md`)

## Shim naming convention

Use explicit prefixes:

- `skill-*` for skill helpers
- `extension-*` for extension helpers

Current shim:

- `shims/skill-web-search` → `~/.pi/agent/skills/web-search/search.py`

## Third-party provenance summary

Some extensions/skills were copied from [`pasky/pi-amplike`](https://github.com/pasky/pi-amplike), commit:

- `25ff804d0cbd5dbf71d9922ac8eb9f0023ce24cd`

Copied files include:

- `extensions/handoff.ts`
- `extensions/modes.ts`
- `extensions/session-query.ts`
- `skills/session-query/SKILL.md`
- `skills/web-search/{SKILL.md,search.py}`
- `skills/visit-webpage/{SKILL.md,visit.py}`

Local adaptations include attribution headers/comments and shim command naming (`skill-web-search`).

License copy:

- `~/.pi/licenses/pi-amplike/LICENSE`
