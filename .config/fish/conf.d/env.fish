status is-interactive; or exit

# editor
set -gx VISUAL nvim
set -gx EDITOR vi

# pager
set -gx MANPAGER 'nvim +Man!'

# gpg-agent
set -gx GPG_TTY (tty)
gpgconf --launch gpg-agent
