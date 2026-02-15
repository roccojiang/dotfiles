#!/usr/bin/env bash
# STEP_NAME="Install fish"
# STEP_GROUP="shell"
# STEP_POLICY="soft"
# STEP_PROMPT_BEFORE="1"
set -euo pipefail

STEP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "${STEP_DIR}/.." && pwd)}"

# shellcheck disable=SC1091
source "${BOOTSTRAP_DIR}/lib/ui.bash"

ensure_fish_installed() {
  if command -v fish >/dev/null 2>&1; then
    ui_note "fish already installed at $(command -v fish)"
    return 10
  fi

  if ! command -v brew >/dev/null 2>&1; then
    ui_warn "Homebrew is required for fish installation but 'brew' is not on PATH"
    return 1
  fi

  ui_info "Installing fish via Homebrew..."
  if brew install fish; then
    ui_note "fish installed at $(command -v fish)"
    return 0
  fi

  ui_warn "Failed to install fish via Homebrew"
  return 1
}

ensure_fish_installed
