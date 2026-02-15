#!/usr/bin/env bash

hostname_short() {
  hostname -s 2>/dev/null || hostname 2>/dev/null || echo "unknown"
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
