function ssh --description="Renames current tmux window to remote hostname"
    if set -q TMUX
        tmux rename-window (echo $argv | cut -d . -f 1)
        command ssh "$argv"
        tmux set-window-option automatic-rename on 1>/dev/null
    else
        command ssh "$argv"
    end
end
