# homebrew
fish_add_path /opt/homebrew/bin

# coursier
fish_add_path "$HOME/Library/Application Support/Coursier/bin"

# ghcup-env
set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME
fish_add_path "$HOME/.cabal/bin"
fish_add_path --append --path "$HOME/.ghcup/bin"

# rustup
source "$HOME/.cargo/env.fish"

# uv
source "$HOME/.local/bin/env.fish"

# jetbrains
fish_add_path "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

# lmstudio cli (lms)
fish_add_path "$HOME/.lmstudio/bin"
