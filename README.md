# dotfiles

Managed using a [bare git repository](https://news.ycombinator.com/item?id=11071754).

## Setup
```sh
git clone --separate-git-dir=$HOME/.dotfiles https://github.com/roccojiang/dotfiles.git dotfiles-tmp
alias dotfiles="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
dotfiles config status.showUntrackedFiles no

cp ~/dotfiles-tmp/.gitmodules ~  # for git submodules
rsync --recursive --verbose --exclude '.git' dotfiles-tmp/ $HOME/
rm -r dotfiles-tmp

# Unified bootstrap entrypoint (safe to re-run)
./install.sh
```

Bootstrap is consolidated in [`install.sh`](install.sh).

### `install.sh` highlights
- Installs Homebrew/fish dependencies where possible.
- Attempts to set fish as the default shell, but **does not fail the install** if `chsh` fails. It prints manual recovery commands instead.
- Bootstraps `~/.pi/agent` symlinks while preserving runtime-local files (for example `auth.json` and `sessions/`).
- Uses host-aware pi-agent config sources:
  - `korora` → shared config at `/Users/Shared/sandbox/pi-agent-config`
  - non-`korora` → per-user config path (`$HOME/dotfiles/pi-agent` if present, else `$HOME/.local/share/pi-agent-config`)

## Notes
### Git submodules
Add git submodules while in the home directory to ensure `.gitmodules` uses relative paths, otherwise git will use absolute paths and that will break GitHub's submodule hyperlinks:

```sh
cd ~
dotfiles submodule add <repository-url> <relative-path>
```
