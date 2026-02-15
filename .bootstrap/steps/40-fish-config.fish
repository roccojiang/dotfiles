#!/usr/bin/env fish

function note
    echo "  -> $argv"
end

if not functions -q fisher
    echo "==> Installing fisher..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    if test $status -ne 0
        echo "WARNING: Failed to fetch fisher installer."
        exit 1
    end

    fisher install jorgebucaran/fisher
    if test $status -ne 0
        echo "WARNING: Failed to install fisher."
        exit 1
    end
else
    note "Fisher already installed."
end

set -l fish_plugins_file ~/.config/fish/fish_plugins
if test -f $fish_plugins_file
    set -l plugins
    for line in (string split \n (cat $fish_plugins_file))
        set line (string trim $line)
        if test -n "$line"
            if not string match -qr '^#' -- $line
                set --append plugins $line
            end
        end
    end

    if test (count $plugins) -gt 0
        echo "==> Installing plugins from $fish_plugins_file..."
        fisher install $plugins
        if test $status -ne 0
            echo "WARNING: Failed to install one or more fish plugins."
            exit 1
        end
    else
        note "No plugin entries found in $fish_plugins_file."
    end
else
    note "No fish_plugins file found at $fish_plugins_file."
end

if type -q tide
    echo "==> Configuring tide..."
    tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time=No --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Sparse --icons='Many icons' --transient=Yes
    if test $status -ne 0
        echo "WARNING: tide configure failed."
        exit 1
    end

    set -U tide_left_prompt_items context colon pwd space git newline character

    if functions -q _tide_find_and_remove
        _tide_find_and_remove context tide_right_prompt_items
    end

    if not set -q tide_right_prompt_items[1]
        set -U tide_right_prompt_items zmx_session
    else if not contains zmx_session $tide_right_prompt_items
        set -U tide_right_prompt_items $tide_right_prompt_items zmx_session
    end

    note "Tide configured. Reload fish for changes to take effect."
else
    note "Tide is not installed; skipping prompt configuration."
end

exit 0
