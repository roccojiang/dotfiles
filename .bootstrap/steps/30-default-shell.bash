#!/usr/bin/env bash
set -euo pipefail

STEP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "${STEP_DIR}/.." && pwd)}"

# shellcheck disable=SC1091
source "${BOOTSTRAP_DIR}/lib/ui.bash"
# shellcheck disable=SC1091
source "${BOOTSTRAP_DIR}/lib/system.bash"
# shellcheck disable=SC1091
source "${BOOTSTRAP_DIR}/lib/shell.bash"

set_default_shell_to_fish
