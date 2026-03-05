# Vendoring workflow (subset + local merge)

This repo vendors selected files from upstream Git repositories using:

- [`.vendor/config.toml`](../.vendor/config.toml): source definitions and selected paths
- [`.vendor/lock.toml`](../.vendor/lock.toml): pinned upstream commit per source
- [`bin/vendor-sync`](../bin/vendor-sync): sync tool

The goal is to keep vendored trees minimal while still allowing local modifications and upstream merges.

## Commands

```sh
./bin/vendor-sync list [source...]
./bin/vendor-sync sync [source...] [--dry-run] [--no-prune]
```

Shorthand defaults to `sync`:

```sh
./bin/vendor-sync
./bin/vendor-sync mitsuhiko-agent-stuff
./bin/vendor-sync --dry-run mitsuhiko-agent-stuff
```

Global options:

- `--config <path>`: config file path (default: `.vendor/config.toml`)
- `--lock <path>`: lock file path (default: `.vendor/lock.toml`)
- `--cache-dir <path>`: upstream clone cache directory (default: `$XDG_CACHE_HOME/dotfiles-vendor` or `~/.cache/dotfiles-vendor`)

Use built-in help for full CLI reference:

```sh
./bin/vendor-sync --help
./bin/vendor-sync sync --help
./bin/vendor-sync list --help
```

## `.vendor/config.toml` schema

```toml
version = 1

[[source]]
name = "example"
url = "https://github.com/example/repo.git"
ref = "main"
dest = "path/in/repo"
prune = true
include = [
  "relative/path/file1",
  "relative/path/file2",
]
```

Source fields:

- `name` (**required**): unique identifier used in CLI
- `url` (**required**): upstream Git URL
- `ref` (default: `main`): branch/tag/ref to sync from
- `dest` (**required**): destination directory inside this repo
- `include` (**required**): explicit list of file paths (relative to upstream repo root)
- `prune` (default: `true`): when true, delete files under `dest` not listed in `include`

Notes:

- `include` currently supports **literal file paths only** (no globs).
- `dest` and `include` must be relative paths and cannot contain `..`.

## `.vendor/lock.toml`

Auto-managed by `vendor-sync`.

```toml
version = 1

[[lock]]
name = "example"
commit = "<40-char sha1>"
```

Do not hand-edit unless you know exactly why.

## Merge behavior

For each tracked file, sync uses a per-file 3-way merge:

- **base**: file at the previously locked commit
- **theirs**: file at the current upstream target commit
- **ours**: local vendored file in this repo

So local customizations are preserved when possible. If both local and upstream changed the same hunk, conflict markers are written and sync exits non-zero.

### First sync (bootstrap)

If a source has no lock entry yet, `base = theirs` (current upstream target). This avoids clobbering existing local edits while establishing the initial lock state.

## Pruning semantics

If `prune = true` (or default):

- files under `dest` that are **not** in `include` are deleted on sync

If `prune = false`:

- extra files under `dest` are kept

You can also disable pruning for one run with `--no-prune`.

## Recommended update workflow

1. Run `./bin/vendor-sync sync <source>`.
2. Review `git diff` and run relevant checks.
3. Commit one source update per commit for easy rollback.

Rollback is then straightforward:

```sh
git revert <commit>
```
