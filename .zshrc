##### zsh4humans #####
# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environment
# variables such as PATH) in this file or in files sourced from it.
#
# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update      'no'
# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:' auto-update-days '28'

# Keyboard type: 'mac' or 'pc'.
zstyle ':z4h:bindkey' keyboard  'mac'

# Don't start tmux.
zstyle ':z4h:' start-tmux       'no'

# Move prompt to the bottom when zsh starts and on Ctrl+L.
zstyle ':z4h:' prompt-at-bottom 'yes'
alias clear=z4h-clear-screen-soft-bottom

# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char 'accept'

# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs 'yes'

# Enable direnv to automatically source .envrc files.
zstyle ':z4h:direnv'         enable 'no'
# Show "loading" and "unloading" notifications from direnv.
zstyle ':z4h:direnv:success' notify 'yes'

# Enable ('yes') or disable ('no') automatic teleportation of z4h over
# SSH when connecting to these hosts.
zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
# The default value if none of the overrides above match the hostname.
zstyle ':z4h:ssh:*'                   enable 'no'

# Send these files over to the remote host when connecting over SSH to the
# enabled hosts.
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

# Prompt configuration.
POSTEDIT=$'\n\n\e[2A'

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

# Extend PATH.
path=(~/bin $path)

# Source additional local files if they exist.
z4h source ~/.env.zsh

# Define key bindings.
z4h bindkey undo Ctrl+/   Shift+Tab  # undo the last command line change
z4h bindkey redo Option+/            # redo the last undone command line change

z4h bindkey z4h-cd-back    Shift+Left   # cd into the previous directory
z4h bindkey z4h-cd-forward Shift+Right  # cd into the next directory
z4h bindkey z4h-cd-up      Shift+Up     # cd into the parent directory
z4h bindkey z4h-cd-down    Shift+Down   # cd into a child directory

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu

##### End zsh4humans #####

## GPG configuration.
export GPG_TTY=$TTY
gpgconf --launch gpg-agent

## Define aliases.
# General purpose aliases
alias tree='tree -a -I .git'
alias g='git'

# Common directories
alias d='cd ~/Developer'

## Default editor as `nvim`, otherwise `vim`
alias vi='nvim'

export VISUAL='nvim'
export EDITOR='vim'

## Homebrew
export HOMEBREW_NO_ENV_HINTS=true
export HOMEBREW_AUTO_UPDATE_SECS=604800

## Use `eza` instead of `ls`
export EZA_ICONS_AUTO=1
alias ls='eza'
alias ll='eza --group-directories-first --long'
alias la='eza --group-directories-first --long --all'
alias l=ll
alias lt='ll --tree --level=3'
alias ltt='ll --tree'

### Tool version management ###
# Most tools managed with `mise`
# See ~/.config/mise/config.toml for globally managed tools
eval "$(/opt/homebrew/bin/mise activate zsh)"

# Haskell managed by `ghcup`
[ -f "/Users/rocco/.ghcup/env" ] && . "/Users/rocco/.ghcup/env"

# Zoxide
eval "$(zoxide init zsh)"

### Functions ###
function _zsh_cd_reminder() {
  if [[ -f .readme ]]; then
    (echo "Reminder from .readme file:" ; echo ; cat .readme) | cowsay -W $(( ${COLUMNS:-80} - 10 ))
  fi
}

autoload -U add-zsh-hook
add-zsh-hook -Uz chpwd _zsh_cd_reminder

function cl() {
  cd "$@" && l
}

# dotfiles
alias dotfiles="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

### zsh completions ###
# Remove homebrew's git completions, so that we use zsh's (better) git completions instead
# See https://github.com/Homebrew/homebrew-core/issues/32081
[ -L /opt/homebrew/share/zsh/site-functions/git-completion.bash ] && rm /opt/homebrew/share/zsh/site-functions/git-completion.bash
[ -L /opt/homebrew/share/zsh/site-functions/_git ] && rm /opt/homebrew/share/zsh/site-functions/_git

### Other tools ###
# LM Studio CLI (lms)
export PATH="$PATH:/Users/rocco/.lmstudio/bin"

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/Users/rocco/.opam/opam-init/init.zsh' ]] || source '/Users/rocco/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration

. "$HOME/.local/bin/env"

# Added by Antigravity
export PATH="/Users/rocco/.antigravity/antigravity/bin:$PATH"
