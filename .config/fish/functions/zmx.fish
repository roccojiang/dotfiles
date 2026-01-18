function zmx --description "zmx wrapper"
    switch $argv[1]
        # Creates and attaches to a new session based on the current directory name,
        # erroring if it already exists as a session.
        case an
            set -l session (path basename -- $PWD)
            set session (string lower -- $session)
            set session (string replace -ar -- '\s+' '-' $session)
            set session (string replace -ar -- '[^a-z0-9-]' '' $session)
            set session (string trim -c '-' -- $session)

            if test -z "$session"
                set session home
            end

            set -l session_lines (command zmx list 2>/dev/null)
            set -l list_status $status

            if test $list_status -ne 0
                printf "zmx failed to list sessions (status %s)\n" $list_status >&2
                return 1
            end

            set -l session_line (string match -e -m1 "$session" -- $session_lines)

            if test -n "$session_line"
                printf "zmx session '%s' already exists:\n> %s\n" $session $session_line >&2
                return 1
            end

            command zmx attach $session $argv[2..-1]
        case '*'
            command zmx $argv
    end
end
