#!/usr/bin/env bash
set -euo pipefail

STEP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "${STEP_DIR}/.." && pwd)}"

# shellcheck disable=SC1091
source "${BOOTSTRAP_DIR}/lib/ui.bash"

PI_AGENT_RUNTIME_DIR="${PI_AGENT_RUNTIME_DIR:-${HOME}/.pi/agent}"
PI_AGENT_SHARED_CONFIG_DIR="${PI_AGENT_SHARED_CONFIG_DIR:-/Users/Shared/sandbox/pi-agent-config}"
PI_AGENT_DEFAULT_CONFIG_DIR="${PI_AGENT_DEFAULT_CONFIG_DIR:-${HOME}/.local/share/pi-agent-config}"
PI_AGENT_LEGACY_CONFIG_DIR="${PI_AGENT_LEGACY_CONFIG_DIR:-${HOME}/dotfiles/pi-agent}"
PI_AGENT_ASSETS=(
  "settings.json"
  "keybindings.json"
  "modes.json"
  "vendor"
  "my-extensions"
  "my-skills"
)

hostname_short() {
  hostname -s 2>/dev/null || hostname 2>/dev/null || echo "unknown"
}

timestamp() {
  date +%Y%m%d%H%M%S
}

backup_with_timestamp() {
  local target="$1"
  local backup_target="${target}.bak.$(timestamp)"

  mv "$target" "$backup_target"
  printf "%s\n" "$backup_target"
}

ensure_git_safe_directory() {
  local directory="$1"

  if [[ ! -d "${directory}/.git" ]]; then
    return 0
  fi

  if git config --global --get-all safe.directory 2>/dev/null | grep -Fxq "$directory"; then
    return 0
  fi

  git config --global --add safe.directory "$directory" >/dev/null 2>&1 || true
}

resolve_pi_agent_config_dir() {
  local host
  host="${BOOTSTRAP_HOSTNAME_SHORT:-$(hostname_short)}"

  if [[ -n "${PI_AGENT_CONFIG_ROOT:-}" ]]; then
    printf "%s\n" "$PI_AGENT_CONFIG_ROOT"
    return 0
  fi

  if [[ "$host" == "korora" ]]; then
    printf "%s\n" "$PI_AGENT_SHARED_CONFIG_DIR"
    return 0
  fi

  if [[ -d "$PI_AGENT_LEGACY_CONFIG_DIR" ]]; then
    printf "%s\n" "$PI_AGENT_LEGACY_CONFIG_DIR"
    return 0
  fi

  printf "%s\n" "$PI_AGENT_DEFAULT_CONFIG_DIR"
}

link_pi_agent_asset() {
  local source="$1"
  local target="$2"
  local name existing_target backup_target

  name="$(basename "$target")"

  if [[ ! -e "$source" ]]; then
    ui_warn "Skipping $name because source asset is missing: $source"
    return 0
  fi

  if [[ -L "$target" ]]; then
    existing_target="$(readlink "$target")"
    if [[ "$existing_target" == "$source" ]]; then
      ui_note "pi-agent $name already linked"
      return 0
    fi

    rm -f "$target"
  elif [[ -e "$target" ]]; then
    backup_target="$(backup_with_timestamp "$target")"
    ui_warn "Backed up existing $name to $backup_target"
  fi

  ln -s "$source" "$target"
  ui_note "Linked $target -> $source"
  return 0
}

bootstrap_pi_agent() {
  local config_dir host
  config_dir="$(resolve_pi_agent_config_dir)"
  host="${BOOTSTRAP_HOSTNAME_SHORT:-$(hostname_short)}"

  ui_info "Bootstrapping pi-agent configuration..."
  ui_note "Host detected: $host"
  ui_note "pi-agent source: $config_dir"
  ui_note "pi-agent runtime: $PI_AGENT_RUNTIME_DIR"

  mkdir -p "$PI_AGENT_RUNTIME_DIR"

  if [[ "$host" == "korora" ]]; then
    mkdir -p "$config_dir"
    chmod g+rwxs "$config_dir" 2>/dev/null || true
    ensure_git_safe_directory "$config_dir"
  elif [[ ! -d "$config_dir" ]]; then
    mkdir -p "$config_dir"
    ui_warn "Created empty per-user pi-agent config directory at $config_dir"
    ui_warn "Populate it and re-run ./install.sh --pi-agent-only"
  fi

  local asset
  for asset in "${PI_AGENT_ASSETS[@]}"; do
    link_pi_agent_asset "$config_dir/$asset" "$PI_AGENT_RUNTIME_DIR/$asset"
  done

  ui_note "Left runtime-only files untouched (for example auth.json and sessions/)"

  if [[ "$host" == "korora" ]]; then
    local missing_assets=0

    for asset in "${PI_AGENT_ASSETS[@]}"; do
      if [[ ! -e "$config_dir/$asset" ]]; then
        missing_assets=1
      fi
    done

    if [[ "$missing_assets" -eq 1 ]]; then
      ui_warn "Shared pi-agent config under $config_dir is incomplete."
      ui_warn "Populate shared assets, then run ./install.sh --pi-agent-only"
    fi
  fi

  return 0
}

bootstrap_pi_agent
