#!/usr/bin/env bash

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  UI_COLOR_INFO=$'\033[1;34m'
  UI_COLOR_NOTE=$'\033[0;36m'
  UI_COLOR_WARN=$'\033[0;33m'
  UI_COLOR_ERROR=$'\033[0;31m'
  UI_COLOR_OK=$'\033[0;32m'
  UI_COLOR_RESET=$'\033[0m'
else
  UI_COLOR_INFO=""
  UI_COLOR_NOTE=""
  UI_COLOR_WARN=""
  UI_COLOR_ERROR=""
  UI_COLOR_OK=""
  UI_COLOR_RESET=""
fi

ui_info() {
  printf "%s==> %s%s\n" "$UI_COLOR_INFO" "$*" "$UI_COLOR_RESET"
}

ui_note() {
  printf "%s  -> %s%s\n" "$UI_COLOR_NOTE" "$*" "$UI_COLOR_RESET"
}

ui_warn() {
  printf "%sWARNING: %s%s\n" "$UI_COLOR_WARN" "$*" "$UI_COLOR_RESET" >&2
}

ui_error() {
  printf "%sERROR: %s%s\n" "$UI_COLOR_ERROR" "$*" "$UI_COLOR_RESET" >&2
}

ui_ok() {
  printf "%s✔ %s%s\n" "$UI_COLOR_OK" "$*" "$UI_COLOR_RESET"
}
