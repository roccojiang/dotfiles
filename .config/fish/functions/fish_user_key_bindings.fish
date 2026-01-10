function fish_user_key_bindings
    # Enable vi-mode bindings, while keeping (non-conflicting) emacs bindings
    # See https://fishshell.com/docs/current/interactive.html#vi-mode-commands
    # This doesn't work if I put it in conf.d, for some reason
    set -g fish_key_bindings fish_vi_key_bindings
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert
end
