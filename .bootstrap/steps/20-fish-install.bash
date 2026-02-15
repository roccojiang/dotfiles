#!/usr/bin/env bash
set -euo pipefail

STEP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "${STEP_DIR}/.." && pwd)}"

# shellcheck disable=SC1091
source "${BOOTSTRAP_DIR}/lib/ui.bash"

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

ensure_fish_installed
