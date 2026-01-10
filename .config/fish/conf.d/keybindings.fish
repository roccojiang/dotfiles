status is-interactive; or exit

# Swap behaviour of fish's `tab` and `shift-tab`
# See https://fishshell.com/docs/current/cmds/bind.html#examples
bind --mode insert tab '
    if commandline --search-field >/dev/null
        commandline -f complete
    else
        commandline -f complete-and-search
    end
'
bind --mode insert shift-tab '
    if commandline --search-field >/dev/null
        commandline -f complete-and-search
    else
        commandline -f complete
    end
'
