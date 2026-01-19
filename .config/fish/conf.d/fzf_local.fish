status is-interactive; or exit

# My personal configs for fzf.fish
# Must be sourced *after* ./fzf.fish, which is defined and managed by the plugin itself

# NOTE: Always use -x flag when setting fzf_* shell variables,
# since fzf.fish executes its commands in child processes

# Use lsd instead of ls for directory previews
set -gx fzf_preview_dir_cmd lsd --oneline --almost-all --group-directories-first --icon=always --color=always

# Show hidden files during "search directory" command
# Respects fd's ~/.config/fd/ignore and global ~/.config/git/ignore
set -gx fzf_fd_opts --hidden --max-depth 5

# Unbind "search directory" command in favour of a more complex setup
fzf_configure_bindings --directory=

# Contextually aware "search directory" command
function _fzf_search_directory_smart
    set -l cmd (commandline -b)

    # Check if we're typing a directory-navigation command
    if string match -qr '^(cd|pushd|z|zi)\s' -- $cmd
        # Temporarily set fd to only search directories
        set -lx fzf_fd_opts --type=directory
        _fzf_search_directory
    else
        _fzf_search_directory
    end
end

bind --mode insert ctrl-o _fzf_search_directory_smart
