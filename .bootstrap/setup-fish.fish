#!/usr/bin/env fish

# Plugin manager (fisher)
if not functions -q fisher
    echo "!! Installing fisher..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
else
    echo "!! Fisher already installed."
end

# Prompt (tide) - also see ~/.config/fish/conf.d/tide_local.fish
if type -q tide
    echo "!! Setting up tide..."

    # 16 colors forces tide to use fish theme colours
    tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time=No --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Sparse --icons='Many icons' --transient=Yes

    # hacky af to remove spacing around the colon, but fuck it
    set -U tide_left_prompt_items context colon pwd space git newline character

    _tide_find_and_remove context tide_right_prompt_items
    set --append tide_right_prompt_items zmx_session

    echo "!! Tide configured. Please reload fish for changes to take effect."
else
    echo "!! Tide is not installed!"
end
