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

# Bootstrap entrypoint (safe to re-run)
./install.sh
```

## Bootstrap architecture

- `~/install.sh` is a thin shim/orchestrator.
- Real implementation is under `~/.bootstrap/`:
  - `~/.bootstrap/lib/*` shared helpers
  - `~/.bootstrap/steps/*` ordered executable steps
- Step runner contract:
  - `0` success
  - `10` skipped/no-op
  - other non-zero failure

### `install.sh` highlights
- Preserves existing flags:
  - `--skip-homebrew`
  - `--skip-shell`
  - `--skip-pi-agent`
  - `--pi-agent-only`
  - `--yes` (auto-confirm prompts)
- Installs Homebrew/fish dependencies where possible.
- Attempts to set fish as default shell; `chsh` failure is non-fatal and prints manual recovery commands.
- Bootstraps `~/.pi/agent` config symlinks while preserving runtime-local files (`auth.json`, `sessions/`).
- Uses host-aware pi-agent source selection:
  - `korora` → `/Users/Shared/sandbox/pi-agent-config`
  - non-`korora` → `$HOME/dotfiles/pi-agent` if present, else `$HOME/.local/share/pi-agent-config`
- Backs up replaced non-symlink files with a timestamp suffix (`.bak.<timestamp>`).

## Notes
### Git submodules
Add git submodules while in the home directory to ensure `.gitmodules` uses relative paths, otherwise git will use absolute paths and that will break GitHub's submodule hyperlinks:

```sh
cd ~
dotfiles submodule add <repository-url> <relative-path>
```
