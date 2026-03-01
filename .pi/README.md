# Pi coding agent configuration

## Layout

| Path | Purpose |
| ------ | --------- |
| [`.pi/agent/`](agent/) | Standard pi config path (includes [`settings.json`](agent/settings.json), extension config files) |
| [`.pi/packages/`](packages/) | Maintained package sources (loaded via [`.pi/agent/settings.json`](agent/settings.json) `packages` entries) |
| [`.pi/shims/`](shims/) | Wrapper commands that replace long package-internal script paths with readable aliases (`skill-*`, `extension-*`), keeping tool invocations concise in pi transcripts |

## Tracked packages

These are locally maintained [package](https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/packages.md) sources for bundled skills and extensions.
I usually make small tweaks to other people's packages for my own setup, so I keep them here as local forks and load them as local-path `packages` instead of via git/npm.
I'll probably add my own first-party packages here too.

| Name | Origin | Local path |
| ------ | ---------- | ------------ |
| `pasky-pi-amplike` | <https://github.com/pasky/pi-amplike> | [`.pi/packages/pasky-pi-amplike`](packages/pasky-pi-amplike/) |

### Upstream sync workflow (using `git subtree`)

Add a new mirror:

```sh
cd ~
dotfiles remote add <name>-upstream <upstream-url>
dotfiles fetch <name>-upstream
dotfiles subtree add --prefix=.pi/packages/<name> <name>-upstream <branch> --squash
```

Pull updates later:

```sh
cd ~
dotfiles fetch <name>-upstream
dotfiles subtree pull --prefix=.pi/packages/<name> <name>-upstream <branch> --squash
```
