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
# left prompt items (hacky custom segments in order to control spacing between segments)
_tide_add_custom_string_segment space ' ' --bg-color normal
_tide_add_custom_string_segment colon ':' --color white --bg-color normal
set -gx tide_left_prompt_separator_same_color ''

# always show "user@hostname" segment
set -gx tide_context_always_display true

# remove icons from pwd segment
set -gx tide_pwd_icon
set -gx tide_pwd_icon_home
set -gx tide_pwd_icon_unwritable

# better git icon
set -gx tide_git_icon ''

# custom zmx session segment (see ../functions/_tide_item_zmx_session.fish)
set -gx tide_zmx_session_color yellow
set -gx tide_zmx_session_bg_color normal
set -gx tide_zmx_session_icon ''

# Configure Tide if it's been installed, but not set up yet
if not set -q tide_left_prompt_items; and type -q tide
    # 16 colors forces tide to use fish theme colours
    tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time=No --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Sparse --icons='Many icons' --transient=Yes

    # hacky af to remove spacing around the colon, but fuck it
    set -U tide_left_prompt_items context colon pwd space git newline character

    _tide_find_and_remove context tide_right_prompt_items
    set --append tide_right_prompt_items zmx_session

    tide reload
end
