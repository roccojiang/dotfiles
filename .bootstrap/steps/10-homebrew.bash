#!/usr/bin/env bash
# STEP_NAME="Homebrew"
# STEP_GROUP="homebrew"
# STEP_POLICY="hard"
# STEP_PROMPT_BEFORE="1"
# STEP_POST_ACTION="load_brew_env"
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

load_brew_env() {
  local brew_bin
  brew_bin="$(find_brew_bin || true)"

  if [[ -z "$brew_bin" ]]; then
    return 1
  fi

  eval "$("$brew_bin" shellenv bash)"
  return 0
}

brew_shellenv_block() {
  cat <<'EOF'
# >>> dotfiles bootstrap: homebrew shellenv >>>
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
# <<< dotfiles bootstrap: homebrew shellenv <<<
EOF
}

upsert_brew_shellenv_block() {
  local file_path="$1"

  touch "$file_path"

  # If Homebrew shellenv is already managed by another snippet, don't duplicate it.
  if grep -Fq 'brew shellenv' "$file_path"; then
    return 10
  fi

  {
    printf "\n"
    brew_shellenv_block
    printf "\n"
  } >> "$file_path"

  return 0
}

ensure_brew_shellenv_persisted() {
  local profile
  local updated_any=0

  for profile in "$HOME/.zprofile" "$HOME/.bash_profile"; do
    if upsert_brew_shellenv_block "$profile"; then
      ui_note "Ensured Homebrew shellenv in $profile"
      updated_any=1
    fi
  done

  if [[ "$updated_any" -eq 1 ]]; then
    return 0
  fi

  return 10
}

print_current_shell_brew_refresh_hint() {
  local brew_bin="$1"
  local shell_name

  shell_name="$(basename "${SHELL:-}")"

  ui_note "To use Homebrew immediately in your current shell session, run:"
  case "$shell_name" in
    fish)
      ui_note "  eval ($brew_bin shellenv fish)"
      ;;
    *)
      ui_note "  eval \"\$($brew_bin shellenv bash)\""
      ;;
  esac
}

ensure_homebrew() {
  local brew_bin
  local brew_was_installed=0
  local env_persist_status=0

  brew_bin="$(find_brew_bin || true)"

  if [[ -n "$brew_bin" ]]; then
    ui_note "Homebrew already available at $brew_bin"
  else
    ui_info "Installing Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
      brew_was_installed=1
      brew_bin="$(find_brew_bin || true)"
      if [[ -n "$brew_bin" ]]; then
        ui_note "Homebrew installed at $brew_bin"
      fi
    fi
  fi

  if [[ -z "$brew_bin" ]]; then
    ui_warn "Homebrew installation failed or brew could not be located afterwards"
    return 1
  fi

  load_brew_env || true
  ensure_brew_shellenv_persisted || env_persist_status=$?
  if [[ "$env_persist_status" -ne 0 && "$env_persist_status" -ne 10 ]]; then
    ui_warn "Could not persist Homebrew shellenv to all shell profiles"
  fi

  if [[ "$brew_was_installed" -eq 1 ]]; then
    print_current_shell_brew_refresh_hint "$brew_bin"
  fi

  if [[ "$brew_was_installed" -eq 1 || "$env_persist_status" -eq 0 ]]; then
    return 0
  fi

  return 10
}

ensure_homebrew
