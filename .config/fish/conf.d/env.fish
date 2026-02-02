status is-interactive; or exit

# editor
set -gx VISUAL nvim
set -gx EDITOR vi

# pager
set -gx MANPAGER 'nvim +Man!'

# gpg-agent
set -gx GPG_TTY (tty)
gpgconf --launch gpg-agent

# homebrew
set -gx HOMEBREW_NO_ENV_HINTS true
set -gx HOMEBREW_AUTO_UPDATE_SECS 604800

if type -q brew
    eval (brew shellenv fish)
else
    for brew_bin in \
        /opt/homebrew/bin/brew \
        /usr/local/bin/brew \
        /home/linuxbrew/.linuxbrew/bin/brew
        if test -x $brew_bin
            eval ($brew_bin shellenv fish)
            break
        end
    end
end

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

# orbstack
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
