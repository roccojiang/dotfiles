#!/usr/bin/env bash

RUNNER_SUCCEEDED=()
RUNNER_SKIPPED=()
RUNNER_FAILED=()

runner_init_log() {
  local log_dir="${1:-${HOME}/.local/state/dotfiles-install}"

  mkdir -p "$log_dir"
  BOOTSTRAP_LOG_FILE="${log_dir}/install-$(date +%Y%m%d-%H%M%S).log"
  : > "$BOOTSTRAP_LOG_FILE"

  ui_note "Logging to $BOOTSTRAP_LOG_FILE"
}

runner_confirm_step() {
  local message="$1"
  local answer

  if [[ "${AUTO_YES:-0}" -eq 1 ]]; then
    ui_note "$message [auto-yes]"
    return 0
  fi

  if [[ ! -t 0 || ! -t 1 ]]; then
    ui_note "$message [non-interactive; auto-yes]"
    return 0
  fi

  while true; do
    read -r -p "$message [Y/n] " answer
    answer="${answer:-Y}"
    case "$answer" in
      [Yy]|[Yy][Ee][Ss])
        return 0
        ;;
      [Nn]|[Nn][Oo])
        return 1
        ;;
      *)
        printf "Please answer y or n.\n"
        ;;
    esac
  done
}

runner_record_success() {
  local step_label="$1"

  RUNNER_SUCCEEDED+=("$step_label")
  ui_ok "${step_label} completed"
}

runner_record_skipped() {
  local step_label="$1"
  local reason="${2:-}"

  if [[ -n "$reason" ]]; then
    RUNNER_SKIPPED+=("${step_label} (${reason})")
    ui_note "${step_label} skipped (${reason})"
    return 0
  fi

  RUNNER_SKIPPED+=("$step_label")
  ui_note "${step_label} skipped"
}

runner_record_failure() {
  local step_label="$1"
  local detail="$2"

  RUNNER_FAILED+=("${step_label} (${detail})")
  ui_warn "${step_label} failed (${detail})"
}

run_step() {
  local step_name="$1"
  local policy="$2"
  local prompt_before="$3"
  shift 3

  local step_label="${step_name}"
  local status=0

  ui_info "$step_label"
  printf "\n----- %s (policy=%s) -----\n" "$step_label" "$policy" >> "$BOOTSTRAP_LOG_FILE"

  if [[ "$prompt_before" -eq 1 ]]; then
    if ! runner_confirm_step "Proceed with ${step_label}?"; then
      runner_record_skipped "$step_label" "user choice"
      return 0
    fi
  fi

  if [[ "$#" -eq 0 ]]; then
    runner_record_failure "$step_label" "no command provided"
    if [[ "$policy" == "soft" ]]; then
      return 0
    fi
    return 1
  fi

  set +e
  "$@" 2>&1 | tee -a "$BOOTSTRAP_LOG_FILE"
  status=${PIPESTATUS[0]}
  set -e

  case "$status" in
    0)
      runner_record_success "$step_label"
      return 0
      ;;
    10)
      runner_record_skipped "$step_label" "reported no-op"
      return 0
      ;;
    *)
      runner_record_failure "$step_label" "exit $status"
      if [[ "$policy" == "soft" ]]; then
        ui_warn "${step_label} is soft-fail; continuing"
        return 0
      fi

      ui_error "${step_label} is hard-fail; aborting"
      return "$status"
      ;;
  esac
}

runner_print_summary() {
  local item
  local succeeded_count skipped_count failed_count

  succeeded_count="${#RUNNER_SUCCEEDED[@]}"
  skipped_count="${#RUNNER_SKIPPED[@]}"
  failed_count="${#RUNNER_FAILED[@]}"

  ui_info "Bootstrap summary"

  printf "  Succeeded: %s\n" "$succeeded_count"
  if [[ "$succeeded_count" -gt 0 ]]; then
    for item in "${RUNNER_SUCCEEDED[@]}"; do
      printf "    - %s\n" "$item"
    done
  fi

  printf "  Skipped:   %s\n" "$skipped_count"
  if [[ "$skipped_count" -gt 0 ]]; then
    for item in "${RUNNER_SKIPPED[@]}"; do
      printf "    - %s\n" "$item"
    done
  fi

  printf "  Failed:    %s\n" "$failed_count"
  if [[ "$failed_count" -gt 0 ]]; then
    for item in "${RUNNER_FAILED[@]}"; do
      printf "    - %s\n" "$item"
    done
  fi
}
