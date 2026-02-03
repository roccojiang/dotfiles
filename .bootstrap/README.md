# Fresh installation setup

## In Bash
The initial setup steps should be run in bash, since my fish config has a few dependencies that need to be installed beforehand.

### 1. Install homebrew

Install [homebrew](https://brew.sh/) using [install-homebrew.bash](install-homebrew.bash). This script will automatically update `$PATH` (and friends) in `.bashrc`, although the shell needs to be reloaded afterwards.

### 2. TODO
TODO: Brewfile, since fish will depend on fzf etc. Also nvim because folke's tokyonight themes live there.

### 3. Set fish as default shell
Install [fish](https://fishshell.com/) and set it as the default shell:
```sh
brew install fish

# In a passwordless Linux environment, it may be worth trying the following instead:
# sudo usermod -s "$(command -v fish)" "$(whoami)"
chsh -s "$(command -v fish)"
```

## In Fish
Further setup should now be conducted in fish.

### 1. Set up fish
Run [setup-fish.fish](setup-fish.fish). **This only ever needs to be run once, during a fresh install!** The script will:
- Install the [fisher](https://github.com/jorgebucaran/fisher) plugin manager, and then install all plugins declared in [~/.config/fish/fish_plugins](.config/fish/fish_plugins).
- Configure the [tide](https://github.com/IlanCosman/tide) prompt.

The shell will need to be reloaded for some changes to take effect.
