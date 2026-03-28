# Pi coding agent configuration

## Layout

| Path | Purpose |
| --- | --- |
| [`.pi/agent/`](agent/) | Standard pi config path (includes [`settings.json`](agent/settings.json), extension config files) |
| [`.pi/shims/`](shims/) | Wrapper commands for local skill helpers (`skill-*`, `extension-*`) |
| [`.pi/packages/`](packages/) | Legacy vendored package copies kept during migration/rollback |

## Shims

Current tracked shims point to helper scripts in `~/agent-skills`:

- `skill-web-search` -> `skills/web-search/search.py`
- `skill-visit-webpage` -> `skills/visit-webpage/visit.py`
