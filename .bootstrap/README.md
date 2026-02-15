# `.bootstrap` implementation

`~/install.sh` is the top-level bootstrap entrypoint.

The real implementation lives under this directory:

- `lib/` shared helpers (CLI parsing, UI/logging, system/fs helpers, Homebrew/shell/pi-agent logic)
- `steps/` executable, ordered bootstrap steps (`bash` and `fish`)

Design goals:

- tiny root `install.sh` shim/orchestrator
- modular, testable step scripts
- consistent runner contract (`0=success`, `10=skipped/no-op`, non-zero=failure)
- safe re-runs (idempotent checks, backup-on-replace symlink behavior)
