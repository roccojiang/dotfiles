status is-interactive; or exit

# Tokyo Night theme, adapted from https://github.com/folke/dot/blob/master/config/fish/conf.d/tokyonight.fish

set style moon

set theme tokyonight_{$style}

set src ~/.local/share/nvim/lazy/tokyonight.nvim/extras/fish_themes/{$theme}.theme
set dst ~/.config/fish/themes/{$theme}.theme

if not test -L $dst
    ln -s $src $dst
end

fish_config theme choose $theme
