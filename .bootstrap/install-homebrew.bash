#!/usr/bin/env bash

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Update PATH in .bashrc, in a platform-agnostic manner
for brew in \
  /opt/homebrew/bin/brew \
  /usr/local/bin/brew \
  /home/linuxbrew/.linuxbrew/bin/brew
do
  if [[ -x "${brew}" ]]; then
    echo >> "${HOME}"/.bashrc
    echo "eval \"\$(${brew} shellenv bash)\"" >> "${HOME}"/.bashrc

    echo "!! Homebrew installed and configured."
    echo "!! Restart your shell or run:"
    echo "    source ~/.bashrc"
    break
  fi
done
