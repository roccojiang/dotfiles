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
  "brew.bash"
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

run_step_file() {
  local step_id="$1"
  local step_name="$2"
  local step_policy="$3"
  local prompt_before="$4"
  local step_file="$5"
  local step_label="[${step_id}] ${step_name}"
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

  run_step "$step_id" "$step_name" "$step_policy" "$prompt_before" "${cmd[@]}" || rc=$?
  if [[ "$rc" -ne 0 ]]; then
    BOOTSTRAP_EXIT_CODE="$rc"
    BOOTSTRAP_ABORTED=1
  fi
}

if [[ "$RUN_HOME_BREW" -eq 1 ]]; then
  run_step_file "10" "Homebrew" "soft" "1" "${BOOTSTRAP_STEPS_DIR}/10-homebrew.bash"

  # Step scripts run in child shells; refresh brew env in this parent shell
  # so downstream steps inherit PATH/HOMEBREW_* variables.
  load_brew_env || true
else
  runner_record_skipped "[10] Homebrew" "--skip-homebrew"
fi

if [[ "$RUN_SHELL_BOOTSTRAP" -eq 1 ]]; then
  run_step_file "20" "Install fish" "soft" "1" "${BOOTSTRAP_STEPS_DIR}/20-fish-install.bash"
  run_step_file "30" "Set default shell to fish" "soft" "1" "${BOOTSTRAP_STEPS_DIR}/30-default-shell.bash"

  if command -v fish >/dev/null 2>&1; then
    run_step_file "40" "Bootstrap fish plugins/prompt" "soft" "1" "${BOOTSTRAP_STEPS_DIR}/40-fish-config.fish"
  else
    runner_record_skipped "[40] Bootstrap fish plugins/prompt" "fish unavailable"
  fi
else
  runner_record_skipped "[20] Install fish" "--skip-shell"
  runner_record_skipped "[30] Set default shell to fish" "--skip-shell"
  runner_record_skipped "[40] Bootstrap fish plugins/prompt" "--skip-shell"
fi

if [[ "$RUN_PI_AGENT_BOOTSTRAP" -eq 1 ]]; then
  run_step_file "50" "Bootstrap pi-agent symlinks" "hard" "1" "${BOOTSTRAP_STEPS_DIR}/50-pi-agent.bash"
else
  runner_record_skipped "[50] Bootstrap pi-agent symlinks" "--skip-pi-agent"
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
