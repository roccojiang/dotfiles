status is-interactive; or exit

# Files & directories
alias ls eza
alias ll "eza --group-directories-first --long"
alias la "eza --group-directories-first --long --all"
abbr l ll
abbr lt "ll --tree --level=3"
abbr ltt "ll --tree"

abbr cl --set-cursor "cd % && ll"

# Editor
abbr vim nvim
abbr vi nvim

# Git
abbr g git
abbr gst "git status"
abbr ga "git add -A"
abbr gcm "git commit -m"
abbr gl "git log --oneline"
abbr gll "git log --oneline --graph"

abbr --command={git,config} st status
abbr --command={git,config} a add
abbr --command={git,config} cm "commit -m"

# Dev
abbr d --set-cursor "cd ~/Developer/%"

# Dotfiles
alias config "git --git-dir=$HOME/.myconf/ --work-tree=$HOME"
