#!/usr/bin/env bash

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
