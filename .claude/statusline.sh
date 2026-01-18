#!/usr/bin/env bash

# Color codes
readonly C_RESET='\033[0m'
readonly C_GRAY='\033[38;5;245m' # explicit gray for default text
readonly C_BAR_EMPTY='\033[38;5;238m'

# Normal 4-bit colors
readonly C_BLACK='\033[30m'
readonly C_RED='\033[31m'
readonly C_GREEN='\033[32m'
readonly C_YELLOW='\033[33m'
readonly C_BLUE='\033[34m'
readonly C_MAGENTA='\033[35m'
readonly C_CYAN='\033[36m'
readonly C_WHITE='\033[37m'

# Bright 4-bit colors
readonly C_BRBLACK='\033[90m'   # bright black (gray)
readonly C_BRRED='\033[91m'     # bright red
readonly C_BRGREEN='\033[92m'   # bright green
readonly C_BRYELLOW='\033[93m'  # bright yellow
readonly C_BRBLUE='\033[94m'    # bright blue
readonly C_BRMAGENTA='\033[95m' # bright magenta
readonly C_BRCYAN='\033[96m'    # bright cyan
readonly C_BRWHITE='\033[97m'   # bright white

input=$(cat)

# Extract model, directory, and cwd
model=$(echo "$input" | jq -r '.model.display_name // .model.id // "?"')
cwd=$(echo "$input" | jq -r '.cwd // empty')
dir=$(basename "$cwd" 2>/dev/null || echo "?")

# Get git branch and status (tide-style)
branch=""
git_status=""
if [[ -n "$cwd" && -d "$cwd" ]]; then
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null)

  # Handle detached HEAD or tags
  if [[ -z "$branch" ]]; then
    tag=$(git -C "$cwd" describe --tags --exact-match 2>/dev/null)
    if [[ -n "$tag" ]]; then
      branch="#${tag}"
    else
      commit=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
      [[ -n "$commit" ]] && branch="@${commit}"
    fi
  fi

  if [[ -n "$branch" ]]; then
    git_parts=()

    # Check upstream (⇡ ahead, ⇣ behind)
    upstream=$(git -C "$cwd" rev-parse --abbrev-ref @{upstream} 2>/dev/null)
    if [[ -n "$upstream" ]]; then
      counts=$(git -C "$cwd" rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
      ahead=$(echo "$counts" | cut -f1)
      behind=$(echo "$counts" | cut -f2)
      [[ "$behind" -gt 0 ]] && git_parts+=("⇣${behind}")
      [[ "$ahead" -gt 0 ]] && git_parts+=("⇡${ahead}")
    fi

    # Stash count (* + count)
    stash_count=$(git -C "$cwd" stash list 2>/dev/null | wc -l | tr -d ' ')
    [[ "$stash_count" -gt 0 ]] && git_parts+=("*${stash_count}")

    # Parse git status for different file states
    staged=0
    conflicts=0
    modified=0
    untracked=0

    while IFS= read -r line; do
      x="${line:0:1}"
      y="${line:1:1}"

      # Conflicts (U in either position, or specific conflict markers)
      if [[ "$x" == "U" || "$y" == "U" || "$x" == "D" && "$y" == "D" || "$x" == "A" && "$y" == "A" ]]; then
        ((conflicts++))
      # Staged (anything in index position that's not a space)
      elif [[ "$x" != " " && "$x" != "?" ]]; then
        ((staged++))
      fi

      # Modified in working tree (y position)
      if [[ "$y" == "M" || "$y" == "D" ]]; then
        ((modified++))
      fi

      # Untracked
      if [[ "$x" == "?" && "$y" == "?" ]]; then
        ((untracked++))
      fi
    done < <(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)

    # Add status indicators (tide style)
    [[ "$conflicts" -gt 0 ]] && git_parts+=("~${conflicts}")
    [[ "$staged" -gt 0 ]] && git_parts+=("+${staged}")
    [[ "$modified" -gt 0 ]] && git_parts+=("!${modified}")
    [[ "$untracked" -gt 0 ]] && git_parts+=("?${untracked}")

    # Join all parts with spaces
    if [[ ${#git_parts[@]} -gt 0 ]]; then
      git_status="${git_parts[*]}"
    fi
  fi
fi

# Function to draw progress bar based on percentage
draw_progress_bar() {
  local pct=$1
  local bar_width=10
  local bar=""

  # Select color based on percentage thresholds
  local bar_color
  if [[ $pct -lt 50 ]]; then
    bar_color="${C_GREEN}"
  elif [[ $pct -lt 75 ]]; then
    bar_color="${C_YELLOW}"
  else
    bar_color="${C_RED}"
  fi

  for ((i = 0; i < bar_width; i++)); do
    bar_start=$((i * 10))
    progress=$((pct - bar_start))
    if [[ $progress -ge 8 ]]; then
      bar+="${bar_color}█${C_RESET}"
    elif [[ $progress -ge 3 ]]; then
      bar+="${bar_color}▄${C_RESET}"
    else
      bar+="${C_BAR_EMPTY}░${C_RESET}"
    fi
  done

  echo "$bar"
}

# Get transcript path for context calculation and last message feature
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

# Get context window size from JSON (accurate), but calculate tokens from transcript
# (more accurate than total_input_tokens which excludes system prompt/tools/memory)
# See: github.com/anthropics/claude-code/issues/13652
max_context=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
max_k=$((max_context / 1000))

# Calculate context bar from transcript
if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
  context_length=$(jq -s '
        map(select(.message.usage and .isSidechain != true and .isApiErrorMessage != true)) |
        last |
        if . then
            (.message.usage.input_tokens // 0) +
            (.message.usage.cache_read_input_tokens // 0) +
            (.message.usage.cache_creation_input_tokens // 0)
        else 0 end
    ' <"$transcript_path")

  # 20k baseline: includes system prompt (~3k), tools (~15k), memory (~300),
  # plus ~2k for git status, env block, XML framing, and other dynamic context
  baseline=20000

  if [[ "$context_length" -gt 0 ]]; then
    pct=$((context_length * 100 / max_context))
    pct_prefix=""
  else
    # At conversation start, ~20k baseline is already loaded
    pct=$((baseline * 100 / max_context))
    pct_prefix="~"
  fi

  [[ $pct -gt 100 ]] && pct=100

  bar=$(draw_progress_bar "$pct")
  ctx="${bar} ${C_GRAY}${pct_prefix}${pct}% of ${max_k}k tokens"
else
  # Transcript not available yet - show baseline estimate
  baseline=20000
  pct=$((baseline * 100 / max_context))
  [[ $pct -gt 100 ]] && pct=100

  bar=$(draw_progress_bar "$pct")
  ctx="${bar} ${C_GRAY}~${pct}% of ${max_k}k tokens"
fi

# Build output: Model | Dir | Branch status | Context
output="${C_YELLOW}${model}${C_GRAY} | ${C_CYAN}${dir}${C_GRAY}"
[[ -n "$branch" ]] && output+=" | ${C_BRGREEN} ${branch}${C_GRAY} ${C_BRYELLOW}${git_status}${C_GRAY}"
output+=" | ${ctx}${C_RESET}"

printf '%b\n' "$output"
