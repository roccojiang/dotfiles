# `.pi` layout and provenance (dotfiles repo)

This repo tracks Pi configuration in a split layout.

This README documents repo-managed `~/.pi/**` layout and provenance.

Operational guardrails and maintenance policy live in `~/.pi/AGENTS.md`.

## Layout

### Pi-native runtime/config (`~/.pi/agent/`)

Keep Pi-native runtime/config here:

- `settings.json`, `modes.json`, `keybindings.json`
- runtime/state files (not typically edited here), e.g. `sessions/`, `auth.json`

`~/.pi/agent/extensions/` and `~/.pi/agent/skills/` are reserved for quick local experiments.
Long-lived extensions/skills should be loaded from `~/.pi/packages` via `settings.json` `packages` entries.

## Dotfiles-owned assets

These live under `~/.pi`:

- `~/.pi/packages/` (all maintained Pi sources: upstream mirrors/forks + first-party packages)
- `~/.pi/shims/`
- docs (`~/.pi/README.md`, `~/.pi/AGENTS.md`)

## Package loading model

Pi loads package sources from `~/.pi/agent/settings.json` using `packages`.

Because paths in that file resolve relative to `~/.pi/agent`, use `../packages/...` for local package directories.

Example:

```json
{
  "packages": [
    {
      "source": "../packages/pi-amplike",
      "extensions": ["extensions/*.ts"],
      "skills": ["skills/web-search/**", "skills/visit-webpage/**"]
    },
    {
      "source": "../packages/rocco-pi"
    }
  ]
}
```

## Upstream mirror workflow (git subtree)

Upstream repositories are mirrored into `~/.pi/packages/<name>` using `dotfiles subtree`.
This preserves upstream layout and keeps hand-merging upstream changes straightforward.

### Add a new upstream mirror (example: pi-amplike)

```sh
cd ~
dotfiles remote add pi-amplike-upstream git@github.com:pasky/pi-amplike.git
dotfiles fetch pi-amplike-upstream
dotfiles subtree add --prefix=.pi/packages/pi-amplike pi-amplike-upstream main --squash
```

### Pull upstream updates later

```sh
cd ~
dotfiles fetch pi-amplike-upstream
dotfiles subtree pull --prefix=.pi/packages/pi-amplike pi-amplike-upstream main --squash
```

Resolve conflicts if needed, then commit.

## Provenance and licensing

- Keep attribution headers/comments when adapting upstream files.
- Keep upstream `LICENSE`/`NOTICE` files within each package directory under `~/.pi/packages/<source>/`.

## Shim naming convention

Use explicit prefixes:

- `skill-*` for skill helpers
- `extension-*` for extension helpers
