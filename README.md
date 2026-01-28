# dotfiles

Managed using a [bare git repository](https://news.ycombinator.com/item?id=11071754).

## Setup
### Initialisation
```sh
git init --bare $HOME/.dotfiles
alias dotfiles="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
dotfiles config status.showUntrackedFiles no
dotfiles remote add origin git@github.com:roccojiang/dotfiles.git
```

### Replication
Untested, but something like this should work.

```sh
git clone --separate-git-dir=$HOME/.dotfiles https://github.com/roccojiang/dotfiles.git dotfiles-tmp
cp ~/dotfiles-tmp/.gitmodules ~  # for git submodules
rsync --recursive --verbose --exclude '.git' dotfiles-tmp/ $HOME/
rm -r dotfiles-tmp
```

## Notes
### Git submodules
Add git submodules while in the home directory to ensure `.gitmodules` uses relative paths, otherwise git will use absolute paths and that will break GitHub's submodule hyperlinks:

```sh
cd ~
dotfiles submodule add <repository-url> <relative-path>
```
