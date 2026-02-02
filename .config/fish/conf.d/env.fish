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
