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
  local block_content

  block_content="$(brew_shellenv_block)"

  python3 - "$file_path" "$block_content" <<'PY'
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
block = sys.argv[2]
start = "# >>> dotfiles bootstrap: homebrew shellenv >>>"
end = "# <<< dotfiles bootstrap: homebrew shellenv <<<"

original = path.read_text() if path.exists() else ""
pattern = re.compile(r"\n*" + re.escape(start) + r"\n.*?\n" + re.escape(end) + r"\n*", re.S)
stripped = re.sub(pattern, "\n", original).rstrip()
if stripped:
    updated = stripped + "\n\n" + block + "\n"
else:
    updated = block + "\n"

if updated == original:
    sys.exit(10)

path.parent.mkdir(parents=True, exist_ok=True)
path.write_text(updated)
sys.exit(0)
PY
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

  if [[ "$brew_was_installed" -eq 1 || "$env_persist_status" -eq 0 ]]; then
    return 0
  fi

  return 10
}
