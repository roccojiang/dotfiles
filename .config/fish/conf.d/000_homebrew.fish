# homebrew needs to be set up early, so that other fish configs
# can assume availability of homebrew-installed programs

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

set -gx HOMEBREW_NO_ENV_HINTS true
set -gx HOMEBREW_AUTO_UPDATE_SECS 604800
