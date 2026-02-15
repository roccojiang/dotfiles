#!/usr/bin/env bash

RUN_HOME_BREW=1
RUN_SHELL_BOOTSTRAP=1
RUN_PI_AGENT_BOOTSTRAP=1
AUTO_YES=0

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Bootstrap dotfiles dependencies and pi-agent symlinks.

Options:
  --skip-homebrew   Skip Homebrew installation checks
  --skip-shell      Skip fish/default-shell/bootstrap steps
  --skip-pi-agent   Skip pi-agent symlink bootstrap
  --pi-agent-only   Only run pi-agent symlink bootstrap
  --yes             Auto-confirm step prompts (non-interactive mode)
  -h, --help        Show this help
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-homebrew)
        RUN_HOME_BREW=0
        ;;
      --skip-shell)
        RUN_SHELL_BOOTSTRAP=0
        ;;
      --skip-pi-agent)
        RUN_PI_AGENT_BOOTSTRAP=0
        ;;
      --pi-agent-only)
        RUN_HOME_BREW=0
        RUN_SHELL_BOOTSTRAP=0
        RUN_PI_AGENT_BOOTSTRAP=1
        ;;
      --yes)
        AUTO_YES=1
        ;;
      -h|--help)
        usage
        return 10
        ;;
      *)
        ui_warn "Unknown option: $1"
        usage
        return 1
        ;;
    esac
    shift
  done

  return 0
}
