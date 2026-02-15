#!/usr/bin/env bash

ensure_fish_installed() {
  if command -v fish >/dev/null 2>&1; then
    ui_note "fish already installed at $(command -v fish)"
    return 10
  fi

  local brew_bin
  brew_bin="$(find_brew_bin || true)"

  if [[ -z "$brew_bin" ]]; then
    ui_warn "fish is not installed and Homebrew is unavailable. Install fish manually."
    return 1
  fi

  ui_info "Installing fish via Homebrew..."
  if "$brew_bin" install fish; then
    ui_note "fish installed at $(command -v fish)"
    return 0
  fi

  ui_warn "Failed to install fish via Homebrew"
  return 1
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
