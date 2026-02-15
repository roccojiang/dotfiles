# `.bootstrap`

Bootstrap implementation for `~/install.sh`.

## Layout

- `lib/` meta-level shared helpers only:
  - `ui.bash` (output formatting)
  - `cli.bash` (flag parsing)
  - `runner.bash` (step execution, prompting, logging, status mapping)
- `steps/` domain logic, one executable step per concern:
  - `10-homebrew.bash`
  - `20-fish-install.bash`
  - `30-default-shell.bash`
  - `40-fish-config.fish`
  - `50-pi-agent.bash`

## Contracts

- Step exit codes:
  - `0` success
  - `10` skipped/no-op
  - any other non-zero failure
- Runner policies:
  - soft-fail steps continue
  - hard-fail steps abort subsequent steps

Step files in `steps/` are expected to include metadata headers (for example `STEP_NAME`, `STEP_GROUP`, `STEP_POLICY`).

For detailed rationale and full conventions, see `./ARCHITECTURE.md`.
