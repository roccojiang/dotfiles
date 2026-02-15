#!/usr/bin/env bash
# STEP_NAME="Set default shell to fish"
# STEP_GROUP="shell"
# STEP_POLICY="soft"
# STEP_PROMPT_BEFORE="1"
set -euo pipefail

STEP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "${STEP_DIR}/.." && pwd)}"

# shellcheck disable=SC1091
source "${BOOTSTRAP_DIR}/lib/ui.bash"

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
    ui_warn "Skipping default shell update because fish is unavailable"
    return 10
  fi

  current_shell="$(current_login_shell || true)"
  if [[ "$current_shell" == "$fish_shell" ]]; then
    ui_note "Default shell already set to fish ($fish_shell)"
    return 10
  fi

  ui_info "Setting default shell to fish..."
  if chsh -s "$fish_shell"; then
    ui_note "Default shell changed to $fish_shell"
    return 0
  fi

  ui_warn "Could not change your default shell automatically."
  ui_warn "Please change it manually with:"
  ui_warn "  chsh -s \"$fish_shell\""
  ui_warn "If chsh keeps failing on Linux, try:"
  ui_warn "  sudo usermod -s \"$fish_shell\" \"$USER\""

  return 1
}

set_default_shell_to_fish
