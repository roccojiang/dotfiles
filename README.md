# dotfiles

Managed using a [bare git repository](https://news.ycombinator.com/item?id=11071754).

## Setup
```sh
git clone --separate-git-dir=$HOME/.dotfiles https://github.com/roccojiang/dotfiles.git dotfiles-tmp
alias dotfiles="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
dotfiles config status.showUntrackedFiles no

cp ~/dotfiles-tmp/.gitmodules ~  # for git submodules
rsync --recursive --verbose --links --exclude '.git' dotfiles-tmp/ $HOME/
rm -r dotfiles-tmp
```

On a fresh install, follow further instructions in [.bootstrap](.bootstrap/).

## Vendoring third-party subsets
Some upstream projects are vendored into this repo as **selected file subsets** (currently for `.pi/packages`).

- [`.vendor/config.toml`](.vendor/config.toml): source definitions + included paths
- [`.vendor/lock.toml`](.vendor/lock.toml): pinned upstream commit per source
- [`bin/vendor-sync`](bin/vendor-sync): sync + merge workflow

(The vendoring metadata lives in hidden `.vendor/` to keep repo-root clutter low.)

Common commands:

```sh
./bin/vendor-sync list
./bin/vendor-sync sync
./bin/vendor-sync sync mitsuhiko-agent-stuff
./bin/vendor-sync --dry-run mitsuhiko-agent-stuff
```

Workflow summary:

1. Edit `.vendor/config.toml` to change tracked sources/files.
2. Run `./bin/vendor-sync sync <source>`.
3. Review `git diff` and run local checks.
4. Commit each source update separately (easy rollback via `git revert <commit>`).

`vendor-sync` performs a per-file 3-way merge (`old upstream` vs `new upstream` vs `local`), so local tweaks are preserved when possible and conflicts are explicit when not.

Full config/CLI reference: [`docs/vendoring.md`](docs/vendoring.md).

For Pi-specific package context, see [`.pi/README.md`](.pi/README.md).

## Notes
### Git submodules
Add git submodules while in the home directory to ensure `.gitmodules` uses relative paths, otherwise git will use absolute paths and that will break GitHub's submodule hyperlinks:

```sh
cd ~
dotfiles submodule add <repository-url> <relative-path>
```
