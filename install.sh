#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOSTNAME_SHORT="$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo unknown)"

PI_AGENT_RUNTIME_DIR="${HOME}/.pi/agent"
PI_AGENT_SHARED_CONFIG_DIR="/Users/Shared/sandbox/pi-agent-config"
PI_AGENT_DEFAULT_CONFIG_DIR="${HOME}/.local/share/pi-agent-config"
PI_AGENT_LEGACY_CONFIG_DIR="${HOME}/dotfiles/pi-agent"
PI_AGENT_ASSETS=(
  "settings.json"
  "keybindings.json"
  "modes.json"
  "vendor"
  "my-extensions"
  "my-skills"
)

RUN_HOME_BREW=1
RUN_SHELL_BOOTSTRAP=1
RUN_PI_AGENT_BOOTSTRAP=1

log() {
  printf "==> %s\n" "$*"
}

note() {
  printf "  -> %s\n" "$*"
}

warn() {
  printf "WARNING: %s\n" "$*" >&2
}

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Bootstrap dotfiles dependencies and pi-agent symlinks.

Options:
  --skip-homebrew   Skip Homebrew installation checks
  --skip-shell      Skip fish/default-shell/bootstrap steps
  --skip-pi-agent   Skip pi-agent symlink bootstrap
  --pi-agent-only   Only run pi-agent symlink bootstrap
  -h, --help        Show this help
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-homebrew)
        RUN_HOME_BREW=0
        ;;
      --skip-shell)
        RUN_SHELL_BOOTSTRAP=0
        ;;
      --skip-pi-agent)
        RUN_PI_AGENT_BOOTSTRAP=0
        ;;
      --pi-agent-only)
        RUN_HOME_BREW=0
        RUN_SHELL_BOOTSTRAP=0
        RUN_PI_AGENT_BOOTSTRAP=1
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        warn "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
    shift
  done
}

find_brew_bin() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return 0
  fi

  local candidate
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    if [[ -x "$candidate" ]]; then
      printf "%s\n" "$candidate"
      return 0
    fi
  done

  return 1
}

load_brew_env() {
  local brew_bin
  brew_bin="$(find_brew_bin || true)"
  if [[ -z "$brew_bin" ]]; then
    return 1
  fi

  eval "$("$brew_bin" shellenv bash)"
  return 0
}

ensure_homebrew() {
  local brew_bin
  brew_bin="$(find_brew_bin || true)"
  if [[ -n "$brew_bin" ]]; then
    note "Homebrew already available at $brew_bin"
    load_brew_env || true
    return 0
  fi

  log "Installing Homebrew..."
  if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    load_brew_env || true
    brew_bin="$(find_brew_bin || true)"
    if [[ -n "$brew_bin" ]]; then
      note "Homebrew installed at $brew_bin"
      return 0
    fi
  fi

  warn "Homebrew installation failed or brew could not be located afterwards"
  return 1
}

ensure_fish_installed() {
  if command -v fish >/dev/null 2>&1; then
    note "fish already installed at $(command -v fish)"
    return 0
  fi

  local brew_bin
  brew_bin="$(find_brew_bin || true)"
  if [[ -z "$brew_bin" ]]; then
    warn "fish is not installed and Homebrew is unavailable. Install fish manually."
    return 1
  fi

  log "Installing fish via Homebrew..."
  if "$brew_bin" install fish; then
    note "fish installed at $(command -v fish)"
    return 0
  fi

  warn "Failed to install fish via Homebrew"
  return 1
}

current_login_shell() {
  if command -v dscl >/dev/null 2>&1; then
    dscl . -read "/Users/${USER}" UserShell 2>/dev/null | awk '{print $2}'
    return 0
  fi

  if command -v getent >/dev/null 2>&1; then
    getent passwd "${USER}" | awk -F: '{print $7}'
    return 0
  fi

  printf "%s\n" "${SHELL:-}"
}

set_default_shell_to_fish() {
  local fish_shell current_shell
  fish_shell="$(command -v fish || true)"
  if [[ -z "$fish_shell" ]]; then
    warn "Skipping default shell update because fish is unavailable"
    return 0
  fi

  current_shell="$(current_login_shell || true)"
  if [[ "$current_shell" == "$fish_shell" ]]; then
    note "Default shell already set to fish ($fish_shell)"
    return 0
  fi

  log "Setting default shell to fish..."
  if chsh -s "$fish_shell"; then
    note "Default shell changed to $fish_shell"
    return 0
  fi

  warn "Could not change your default shell automatically."
  warn "Please change it manually with:"
  warn "  chsh -s \"$fish_shell\""
  warn "If chsh keeps failing on Linux, try:"
  warn "  sudo usermod -s \"$fish_shell\" \"$USER\""

  return 0
}

setup_fish_plugins_and_prompt() {
  if ! command -v fish >/dev/null 2>&1; then
    warn "Skipping fish bootstrap because fish is unavailable"
    return 0
  fi

  log "Bootstrapping fish plugins and prompt..."
  if fish <<'FISH_BOOTSTRAP'
if not functions -q fisher
    echo "!! Installing fisher..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
else
    echo "!! Fisher already installed."
end

set -l fish_plugins_file ~/.config/fish/fish_plugins
if test -f $fish_plugins_file
    set -l plugins
    for line in (string split \n (cat $fish_plugins_file))
        set line (string trim $line)
        if test -n "$line"
            if not string match -qr '^#' -- $line
                set --append plugins $line
            end
        end
    end

    if test (count $plugins) -gt 0
        fisher install $plugins
    end
else
    echo "!! No fish_plugins file found at $fish_plugins_file."
end

if type -q tide
    echo "!! Setting up tide..."
    tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time=No --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Sparse --icons='Many icons' --transient=Yes

    set -U tide_left_prompt_items context colon pwd space git newline character

    if functions -q _tide_find_and_remove
        _tide_find_and_remove context tide_right_prompt_items
    end

    if not set -q tide_right_prompt_items[1]
        set -U tide_right_prompt_items zmx_session
    else if not contains zmx_session $tide_right_prompt_items
        set -U tide_right_prompt_items $tide_right_prompt_items zmx_session
    end

    echo "!! Tide configured. Please reload fish for changes to take effect."
else
    echo "!! Tide is not installed!"
end
FISH_BOOTSTRAP
  then
    note "fish plugin bootstrap completed"
  else
    warn "fish bootstrap failed. Re-run later in fish if needed"
  fi
}

resolve_pi_agent_config_dir() {
  if [[ -n "${PI_AGENT_CONFIG_ROOT:-}" ]]; then
    printf "%s\n" "$PI_AGENT_CONFIG_ROOT"
    return 0
  fi

  if [[ "$HOSTNAME_SHORT" == "korora" ]]; then
    printf "%s\n" "$PI_AGENT_SHARED_CONFIG_DIR"
    return 0
  fi

  if [[ -d "$PI_AGENT_LEGACY_CONFIG_DIR" ]]; then
    printf "%s\n" "$PI_AGENT_LEGACY_CONFIG_DIR"
    return 0
  fi

  printf "%s\n" "$PI_AGENT_DEFAULT_CONFIG_DIR"
}

ensure_git_safe_directory() {
  local directory="$1"
  if [[ ! -d "$directory/.git" ]]; then
    return 0
  fi

  if git config --global --get-all safe.directory 2>/dev/null | grep -Fxq "$directory"; then
    return 0
  fi

  git config --global --add safe.directory "$directory" >/dev/null 2>&1 || true
}

timestamp() {
  date +%Y%m%d%H%M%S
}

link_pi_agent_asset() {
  local source="$1"
  local target="$2"
  local name existing_target backup_target

  name="$(basename "$target")"

  if [[ ! -e "$source" ]]; then
    warn "Skipping $name because source asset is missing: $source"
    return 0
  fi

  if [[ -L "$target" ]]; then
    existing_target="$(readlink "$target")"
    if [[ "$existing_target" == "$source" ]]; then
      note "pi-agent $name already linked"
      return 0
    fi
    rm -f "$target"
  elif [[ -e "$target" ]]; then
    backup_target="${target}.bak.$(timestamp)"
    mv "$target" "$backup_target"
    warn "Backed up existing $name to $backup_target"
  fi

  ln -s "$source" "$target"
  note "Linked $target -> $source"
}

bootstrap_pi_agent() {
  local config_dir
  config_dir="$(resolve_pi_agent_config_dir)"

  log "Bootstrapping pi-agent configuration..."
  note "Host detected: $HOSTNAME_SHORT"
  note "pi-agent source: $config_dir"
  note "pi-agent runtime: $PI_AGENT_RUNTIME_DIR"

  mkdir -p "$PI_AGENT_RUNTIME_DIR"

  if [[ "$HOSTNAME_SHORT" == "korora" ]]; then
    mkdir -p "$config_dir"
    chmod g+rwxs "$config_dir" 2>/dev/null || true
    ensure_git_safe_directory "$config_dir"
  elif [[ ! -d "$config_dir" ]]; then
    mkdir -p "$config_dir"
    warn "Created empty per-user pi-agent config directory at $config_dir"
    warn "Populate it and re-run ./install.sh --pi-agent-only"
  fi

  local asset
  for asset in "${PI_AGENT_ASSETS[@]}"; do
    link_pi_agent_asset "$config_dir/$asset" "$PI_AGENT_RUNTIME_DIR/$asset"
  done

  note "Left runtime-only files untouched (for example auth.json and sessions/)"

  if [[ "$HOSTNAME_SHORT" == "korora" ]]; then
    local missing_assets=0
    for asset in "${PI_AGENT_ASSETS[@]}"; do
      if [[ ! -e "$config_dir/$asset" ]]; then
        missing_assets=1
      fi
    done

    if [[ "$missing_assets" -eq 1 ]]; then
      warn "Shared pi-agent config under $config_dir is incomplete."
      warn "Populate shared assets, then run ./install.sh --pi-agent-only"
    fi
  fi
}

main() {
  parse_args "$@"

  log "Starting bootstrap from $REPO_ROOT"

  if [[ "$RUN_HOME_BREW" -eq 1 ]]; then
    ensure_homebrew || warn "Continuing without Homebrew"
  fi

  if [[ "$RUN_SHELL_BOOTSTRAP" -eq 1 ]]; then
    ensure_fish_installed || true
    set_default_shell_to_fish
    setup_fish_plugins_and_prompt
  fi

  if [[ "$RUN_PI_AGENT_BOOTSTRAP" -eq 1 ]]; then
    bootstrap_pi_agent
  fi

  log "Bootstrap complete"
  note "Restart your shell to pick up shell changes"
}

main "$@"
