# AGENTS.md — Dotfiles dev + test playbook

Use this file for safe, repeatable work in this repo.

## Repo model (important)

These dotfiles are managed as a **bare repo** on the real machine:

- Bare repo: `~/.dotfiles/`
- Work tree: `~`
- Alias:
  ```sh
  alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
  ```

Do normal editing/testing in a safe, separate dev checkout, not directly against real `~`.

## exe.dev sandbox workflow (preferred)

1. Create VM:
   ```sh
   ssh exe.dev "new --name=dotfiles-sandbox"
   ```
2. Start local tmux:
   ```sh
   tmux new-session -d -s dotfiles-test
   ```
3. SSH from tmux and capture output:
   ```sh
   tmux send-keys -t dotfiles-test 'ssh dotfiles-sandbox.exe.xyz' Enter
   sleep 5
   tmux capture-pane -pt dotfiles-test -S -50
   ```
4. Run commands via `tmux send-keys`; always `sleep` then `capture-pane`.
5. Get code onto VM (clone branch under test, or `rsync` local changes).
6. Run smoke test:
   ```sh
   tmux send-keys -t dotfiles-test 'cd ~/dotfiles && ./install.sh --yes --skip-homebrew' Enter
   sleep 30
   tmux capture-pane -pt dotfiles-test -S -80
   ```
7. Tear down when done:
   ```sh
   ssh exe.dev "rm dotfiles-sandbox"
   tmux kill-session -t dotfiles-test
   ```

For long-running commands, pipe to a log and tail it from tmux.

## Pi-specific notes

Keep root guidance minimal. Pi runtime/layout maintenance lives in:

- `.pi/AGENTS.md`

## Safety rules (non-negotiable)

1. Never apply dotfiles directly to real `~` mid-dev without explicit approval.
2. Never run `install.sh` without `--yes` in non-interactive tests.
3. Always validate changes in an ephemeral sandbox first.
4. Be careful with bare-repo commands (`~` is the work tree).
5. Do not expose sensitive file contents.
