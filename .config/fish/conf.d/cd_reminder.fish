# Event handlers can't rely on autoloading, so this has to live in conf.d (see https://fishshell.com/docs/current/language.html#event)
# Closest equivalent to zsh's chpwd hook is an --on-variable hook with $PWD
# See https://github.com/fish-shell/fish-shell/issues/583#issuecomment-13758325
function __cd_reminder --on-variable PWD -d "Prints a reminder from a .readme file, if it exists in the current directory"
    status is-command-substitution; and return

    if test -f .readme
        if test -n $COLUMNS
            set columns (math $COLUMNS - 10)
        else
            set columns 70
        end

        printf 'Reminder from .readme:\n\n%s\n' "$(cat .readme)" | cowsay -W $columns
    end
end
