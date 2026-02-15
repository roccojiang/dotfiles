#!/usr/bin/env bash

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
    ui_note "Homebrew already available at $brew_bin"
    load_brew_env || true
    return 10
  fi

  ui_info "Installing Homebrew..."
  if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    load_brew_env || true
    brew_bin="$(find_brew_bin || true)"
    if [[ -n "$brew_bin" ]]; then
      ui_note "Homebrew installed at $brew_bin"
      return 0
    fi
  fi

  ui_warn "Homebrew installation failed or brew could not be located afterwards"
  return 1
}
