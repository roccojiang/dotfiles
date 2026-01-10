status is-interactive; or exit

# gpg-agent
set -gx GPG_TTY (tty)
gpgconf --launch gpg-agent

# eza
set -gx EZA_ICONS_AUTO

# editor
set -gx VISUAL nvim
set -gx EDITOR vi
