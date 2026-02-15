#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="${REPO_ROOT}/.bootstrap"
BOOTSTRAP_LIB_DIR="${BOOTSTRAP_DIR}/lib"
BOOTSTRAP_STEPS_DIR="${BOOTSTRAP_DIR}/steps"

required_libs=(
  "ui.bash"
  "cli.bash"
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

hostname_short() {
  hostname -s 2>/dev/null || hostname 2>/dev/null || echo "unknown"
}

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

STEP_PLAN_TOTAL=0
STEP_PLAN_INDEX=0
NEXT_STEP_PROGRESS=""
STEP_FILES=()
STEP_NAMES=()
STEP_POLICIES=()
STEP_PROMPTS=()
STEP_GROUPS=()
STEP_REQUIRES_COMMANDS=()
STEP_POST_ACTIONS=()

next_step_progress() {
  STEP_PLAN_INDEX=$((STEP_PLAN_INDEX + 1))
  NEXT_STEP_PROGRESS="Step ${STEP_PLAN_INDEX}/${STEP_PLAN_TOTAL}"
}

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

humanize_step_filename() {
  local file_name="$1"
  local stem

  stem="${file_name%.*}"
  stem="${stem#[0-9][0-9]-}"
  stem="${stem//-/ }"

  printf "%s\n" "$stem"
}

step_meta() {
  local step_file="$1"
  local key="$2"
  local default_value="${3:-}"
  local value

  value="$(awk -v key="$key" '
    {
      pattern = "^#[[:space:]]*" key "=\""
      if ($0 ~ pattern) {
        line = $0
        sub(pattern, "", line)
        sub("\"[[:space:]]*$", "", line)
        print line
        exit
      }
    }
  ' "$step_file")"

  if [[ -n "$value" ]]; then
    printf "%s\n" "$value"
    return 0
  fi

  printf "%s\n" "$default_value"
}

discover_step_plan() {
  local step_file base_name
  local step_name step_policy step_prompt step_group step_requires step_post_action

  while IFS= read -r step_file; do
    base_name="$(basename "$step_file")"

    step_name="$(step_meta "$step_file" "STEP_NAME" "$(humanize_step_filename "$base_name")")"
    step_policy="$(step_meta "$step_file" "STEP_POLICY" "soft")"
    step_prompt="$(step_meta "$step_file" "STEP_PROMPT_BEFORE" "1")"
    step_group="$(step_meta "$step_file" "STEP_GROUP" "default")"
    step_requires="$(step_meta "$step_file" "STEP_REQUIRES_COMMAND" "")"
    step_post_action="$(step_meta "$step_file" "STEP_POST_ACTION" "")"

    if [[ "$step_policy" != "soft" && "$step_policy" != "hard" ]]; then
      ui_warn "${base_name}: unsupported STEP_POLICY='${step_policy}', defaulting to soft"
      step_policy="soft"
    fi

    if [[ "$step_prompt" != "0" && "$step_prompt" != "1" ]]; then
      ui_warn "${base_name}: unsupported STEP_PROMPT_BEFORE='${step_prompt}', defaulting to 1"
      step_prompt="1"
    fi

    STEP_FILES+=("$step_file")
    STEP_NAMES+=("$step_name")
    STEP_POLICIES+=("$step_policy")
    STEP_PROMPTS+=("$step_prompt")
    STEP_GROUPS+=("$step_group")
    STEP_REQUIRES_COMMANDS+=("$step_requires")
    STEP_POST_ACTIONS+=("$step_post_action")
  done < <(find "$BOOTSTRAP_STEPS_DIR" -maxdepth 1 -type f \( -name "*.bash" -o -name "*.fish" \) | sort)

  STEP_PLAN_TOTAL="${#STEP_FILES[@]}"
}

run_step_file() {
  local step_name="$1"
  local step_policy="$2"
  local prompt_before="$3"
  local step_file="$4"
  local step_label="${step_name}"
  local step_progress=""
  local rc=0
  local cmd=()

  next_step_progress
  step_progress="$NEXT_STEP_PROGRESS"

  if [[ "$BOOTSTRAP_ABORTED" -eq 1 ]]; then
    ui_info "${step_progress}: ${step_name}"
    runner_record_skipped "${step_progress}: ${step_label}" "blocked by earlier hard-fail"
    return 0
  fi

  if [[ ! -f "$step_file" ]]; then
    ui_info "${step_progress}: ${step_name}"
    runner_record_failure "${step_progress}: ${step_label}" "missing step file: ${step_file}"
    BOOTSTRAP_EXIT_CODE=1
    BOOTSTRAP_ABORTED=1
    return 0
  fi

  case "$step_file" in
    *.bash)
      cmd=(env PI_BOOTSTRAP_FORCE_COLOR=1 bash "$step_file")
      ;;
    *.fish)
      cmd=(env PI_BOOTSTRAP_FORCE_COLOR=1 fish "$step_file")
      ;;
    *)
      cmd=("$step_file")
      ;;
  esac

  run_step "$step_name" "$step_policy" "$prompt_before" "$step_progress" "${cmd[@]}" || rc=$?
  if [[ "$rc" -ne 0 ]]; then
    BOOTSTRAP_EXIT_CODE="$rc"
    BOOTSTRAP_ABORTED=1
  fi
}

skip_planned_step() {
  local step_name="$1"
  local reason="$2"
  local step_progress

  next_step_progress
  step_progress="$NEXT_STEP_PROGRESS"
  ui_info "${step_progress}: ${step_name}"
  runner_record_skipped "${step_progress}: ${step_name}" "$reason"
}

discover_step_plan

if [[ "$STEP_PLAN_TOTAL" -eq 0 ]]; then
  ui_warn "No bootstrap step files found in ${BOOTSTRAP_STEPS_DIR}"
fi

HAS_SHELL_STEPS=0

for i in "${!STEP_FILES[@]}"; do
  step_file="${STEP_FILES[$i]}"
  step_name="${STEP_NAMES[$i]}"
  step_policy="${STEP_POLICIES[$i]}"
  step_prompt="${STEP_PROMPTS[$i]}"
  step_group="${STEP_GROUPS[$i]}"
  step_requires="${STEP_REQUIRES_COMMANDS[$i]}"
  step_post_action="${STEP_POST_ACTIONS[$i]}"

  if [[ "$step_group" == "shell" ]]; then
    HAS_SHELL_STEPS=1
  fi

  case "$step_group" in
    homebrew)
      if [[ "$RUN_HOME_BREW" -eq 0 ]]; then
        skip_planned_step "$step_name" "--skip-homebrew"
        continue
      fi
      ;;
    shell)
      if [[ "$RUN_SHELL_BOOTSTRAP" -eq 0 ]]; then
        skip_planned_step "$step_name" "--skip-shell"
        continue
      fi
      ;;
    pi-agent)
      if [[ "$RUN_PI_AGENT_BOOTSTRAP" -eq 0 ]]; then
        skip_planned_step "$step_name" "--skip-pi-agent"
        continue
      fi
      ;;
  esac

  if [[ -n "$step_requires" ]] && ! command -v "$step_requires" >/dev/null 2>&1; then
    skip_planned_step "$step_name" "${step_requires} unavailable"
    continue
  fi

  run_step_file "$step_name" "$step_policy" "$step_prompt" "$step_file"

  case "$step_post_action" in
    load_brew_env)
      # Step scripts run in child shells; refresh brew env in this parent shell
      # so downstream steps inherit PATH/HOMEBREW_* variables.
      load_brew_env || true
      ;;
  esac
done

runner_print_summary
ui_note "Detailed log: ${BOOTSTRAP_LOG_FILE}"

if [[ "$RUN_SHELL_BOOTSTRAP" -eq 1 && "$HAS_SHELL_STEPS" -eq 1 ]]; then
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
