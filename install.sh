#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="${REPO_ROOT}/.bootstrap"
BOOTSTRAP_LIB_DIR="${BOOTSTRAP_DIR}/lib"
BOOTSTRAP_STEPS_DIR="${BOOTSTRAP_DIR}/steps"

required_libs=(
  "ui.bash"
  "cli.bash"
  "system.bash"
  "fs.bash"
  "shell.bash"
  "pi_agent.bash"
  "runner.bash"
)

for lib_file in "${required_libs[@]}"; do
  if [[ ! -f "${BOOTSTRAP_LIB_DIR}/${lib_file}" ]]; then
    printf "Missing bootstrap library: %s\n" "${BOOTSTRAP_LIB_DIR}/${lib_file}" >&2
    exit 1
  fi

  # shellcheck disable=SC1090
  source "${BOOTSTRAP_LIB_DIR}/${lib_file}"
done

parse_status=0
parse_args "$@" || parse_status=$?
case "$parse_status" in
  0)
    ;;
  10)
    exit 0
    ;;
  *)
    exit "$parse_status"
    ;;
esac

BOOTSTRAP_HOSTNAME_SHORT="$(hostname_short)"
BOOTSTRAP_EXIT_CODE=0
BOOTSTRAP_ABORTED=0

export REPO_ROOT
export BOOTSTRAP_DIR
export BOOTSTRAP_LIB_DIR
export BOOTSTRAP_STEPS_DIR
export BOOTSTRAP_HOSTNAME_SHORT

runner_init_log "${HOME}/.local/state/dotfiles-install"

ui_info "Starting bootstrap from ${REPO_ROOT}"
ui_note "Host detected: ${BOOTSTRAP_HOSTNAME_SHORT}"
if [[ "$AUTO_YES" -eq 1 ]]; then
  ui_note "Auto-confirm enabled (--yes)"
fi

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

run_step_file() {
  local step_name="$1"
  local step_policy="$2"
  local prompt_before="$3"
  local step_file="$4"
  local step_label="${step_name}"
  local rc=0
  local cmd=()

  if [[ "$BOOTSTRAP_ABORTED" -eq 1 ]]; then
    runner_record_skipped "$step_label" "blocked by earlier hard-fail"
    return 0
  fi

  if [[ ! -f "$step_file" ]]; then
    runner_record_failure "$step_label" "missing step file: ${step_file}"
    BOOTSTRAP_EXIT_CODE=1
    BOOTSTRAP_ABORTED=1
    return 0
  fi

  case "$step_file" in
    *.bash)
      cmd=(bash "$step_file")
      ;;
    *.fish)
      cmd=(fish "$step_file")
      ;;
    *)
      cmd=("$step_file")
      ;;
  esac

  run_step "$step_name" "$step_policy" "$prompt_before" "${cmd[@]}" || rc=$?
  if [[ "$rc" -ne 0 ]]; then
    BOOTSTRAP_EXIT_CODE="$rc"
    BOOTSTRAP_ABORTED=1
  fi
}

if [[ "$RUN_HOME_BREW" -eq 1 ]]; then
  run_step_file "Homebrew" "soft" "1" "${BOOTSTRAP_STEPS_DIR}/10-homebrew.bash"

  # Step scripts run in child shells; refresh brew env in this parent shell
  # so downstream steps inherit PATH/HOMEBREW_* variables.
  load_brew_env || true
else
  runner_record_skipped "Homebrew" "--skip-homebrew"
fi

if [[ "$RUN_SHELL_BOOTSTRAP" -eq 1 ]]; then
  run_step_file "Install fish" "soft" "1" "${BOOTSTRAP_STEPS_DIR}/20-fish-install.bash"
  run_step_file "Set default shell to fish" "soft" "1" "${BOOTSTRAP_STEPS_DIR}/30-default-shell.bash"

  if command -v fish >/dev/null 2>&1; then
    run_step_file "Bootstrap fish plugins/prompt" "soft" "1" "${BOOTSTRAP_STEPS_DIR}/40-fish-config.fish"
  else
    runner_record_skipped "Bootstrap fish plugins/prompt" "fish unavailable"
  fi
else
  runner_record_skipped "Install fish" "--skip-shell"
  runner_record_skipped "Set default shell to fish" "--skip-shell"
  runner_record_skipped "Bootstrap fish plugins/prompt" "--skip-shell"
fi

if [[ "$RUN_PI_AGENT_BOOTSTRAP" -eq 1 ]]; then
  run_step_file "Bootstrap pi-agent symlinks" "hard" "1" "${BOOTSTRAP_STEPS_DIR}/50-pi-agent.bash"
else
  runner_record_skipped "Bootstrap pi-agent symlinks" "--skip-pi-agent"
fi

runner_print_summary
ui_note "Detailed log: ${BOOTSTRAP_LOG_FILE}"

if [[ "$RUN_SHELL_BOOTSTRAP" -eq 1 ]]; then
  ui_note "Restart your shell to pick up shell changes"
fi

if [[ "$BOOTSTRAP_EXIT_CODE" -ne 0 ]]; then
  ui_error "Bootstrap finished with hard-failures"
  exit "$BOOTSTRAP_EXIT_CODE"
fi

if [[ "${#RUNNER_FAILED[@]}" -gt 0 ]]; then
  ui_warn "Bootstrap completed with non-fatal step failures"
else
  ui_ok "Bootstrap complete"
fi
