status is-interactive; or exit

function _tide_add_custom_string_segment -a name value
    argparse 'c/color=' 'b/bg-color=' -- $argv

    if not functions -q _tide_item_$name
        eval "
        function _tide_item_$name
          _tide_print_item $name '$value'
        end
        "
        funcsave _tide_item_$name
    end

    if set -q _flag_color
        set -gx tide_{$name}_color $_flag_color
    end

    if set -q _flag_bg_color
        set -gx tide_{$name}_bg_color $_flag_bg_color
    end
end

# Prompt configuration
_tide_add_custom_string_segment space ' ' --bg-color normal
_tide_add_custom_string_segment colon ':' --color white --bg-color normal

set -gx tide_left_prompt_separator_same_color ''

set -gx tide_context_always_display true

set -gx tide_pwd_icon
set -gx tide_pwd_icon_home
set -gx tide_pwd_icon_unwritable

set -gx tide_git_icon ''

# Configure Tide if it's been installed, but not set up yet
if not set -q tide_left_prompt_items; and type -q tide
    # 16 colors forces tide to use fish theme colours
    tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time=No --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Sparse --icons='Many icons' --transient=Yes

    # hacky af to remove spacing around the colon, but fuck it
    set -U tide_left_prompt_items context colon pwd space git newline character

    _tide_find_and_remove context tide_right_prompt_items

    tide reload
end
