# set -x # useful for debugging

# We want to set our PATH variable only when fish is being loaded in the login
# mode, so it won't mess up when we enter tmux session. Check this for info:
#
# - https://fishshell.com/docs/current/#default-shell
# - https://fishshell.com/docs/current/#configuration

if status is-login
    # --path option allows us to manipulate PATH directly, see more:
    # https://fishshell.com/docs/current/cmds/fish_add_path.html
    fish_add_path --path $HOME/.dotfiles/littles/
    fish_add_path --path $HOME/.mix/escripts
    fish_add_path --path $HOME/.local/bin

    if not command -s brew >/dev/null
        and test -x /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv)
    end

    if not set -q ASDF_DIR
        source (brew --prefix asdf)"/libexec/asdf.fish"
    end
end
