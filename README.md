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

## Bootstrap

- Entry point: `./install.sh`
- Implementation: `~/.bootstrap/`
- Supported flags:
  - `--skip-homebrew`
  - `--skip-shell`
  - `--skip-pi-agent`
  - `--pi-agent-only`
  - `--yes`

For bootstrap internals and conventions:

- `~/.bootstrap/README.md`
- `~/.bootstrap/ARCHITECTURE.md`

## Notes

### Git submodules

Add git submodules while in the home directory to ensure `.gitmodules` uses relative paths, otherwise git will use absolute paths and that will break GitHub's submodule hyperlinks:

```sh
cd ~
dotfiles submodule add <repository-url> <relative-path>
```
