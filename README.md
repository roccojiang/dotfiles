# Dotfiles

My current preferred usage style (see https://www.chezmoi.io/user-guide/frequently-asked-questions/usage/):
* Edit files in home directory / wherever they actually live
* Re-add specific files to chezmoi using `chezmoi add $FILE`, or re-add all files using `chezmoi re-add`
* Commit and push to git

This won't work well for multi-machine setups, but for now it works and makes it easier to configure files which may be externally modified (e.g. vscode settings, kitty settings since I like opening it with `cmd+,`)

