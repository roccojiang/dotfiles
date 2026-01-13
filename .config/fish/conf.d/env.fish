status is-interactive; or exit

# editor
set -gx VISUAL nvim
set -gx EDITOR vi

# eza
set -gx EZA_ICONS_AUTO

# gpg-agent
set -gx GPG_TTY (tty)
gpgconf --launch gpg-agent

# homebrew
set -gx HOMEBREW_NO_ENV_HINTS true
set -gx HOMEBREW_AUTO_UPDATE_SECS 604800
