# dotfiles

Managed using a [bare git repository](https://news.ycombinator.com/item?id=11071754).

## Setup
```sh
git init --bare $HOME/.dotfiles
alias dotfiles="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
dotfiles config status.showUntrackedFiles no
dotfiles remote add origin git@github.com:roccojiang/dotfiles.git
```

## Replication
Untested, but something like this should work.

```sh
git clone --separate-git-dir=$HOME/.dotfiles git@github.com:roccojiang/dotfiles.git dotfiles-tmp
cp ~/dotfiles-tmp/.gitmodules ~  # for git submodules
rsync --recursive --verbose --exclude '.git' dotfiles-tmp/ $HOME/
rm -r dotfiles-tmp
```
