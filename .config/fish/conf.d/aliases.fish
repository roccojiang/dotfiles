status is-interactive; or exit

# files & directories
alias ls eza
alias ll "eza --group-directories-first --long"
alias la "eza --group-directories-first --long --all"
abbr l ll
abbr lt "ll --tree --level=3"
abbr ltt "ll --tree"

abbr cl --set-cursor "cd % && ll"

# common directories
abbr d --set-cursor "cd ~/Developer/% && ll"
abbr notes --set-cursor "cd ~/Documents/obsidian-vault/%"

# editor
abbr vim nvim
abbr vi nvim

# git
abbr g git

# dynamically generate abbreviations for all git aliases defined in ~/.config/git/config,
# except for those defined in the below git_alias_exclusions list 
# inspired by https://github.com/timomeh/dotfiles/blob/1500c4bbfc4d524a71fc7242b2a4acf6fdedf16c/.config/fish/config.fish#L30-L33
set git_alias_exclusions dlog dshow ddiff

for line in (git config -l | rg alias | cut -c 7-)
    set parts (string split -m 1 '=' $line)
    set alias $parts[1]
    set cmd $parts[2]

    if contains $alias $git_alias_exclusions
        continue
    end

    abbr "g$alias" "git $cmd"
    abbr --command={git,dotfiles} $alias $cmd
end

# dotfiles
alias dotfiles "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
