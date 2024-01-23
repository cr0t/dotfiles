function ssh --description="Renames current tmux window to remote hostname"
    if set -q TMUX
        # use last parameter as domain name, for example from `ssh -v summercode.com`
        # it will retrieve `summercode` and assign to $ssh_host
        set --local ssh_host (echo $argv | rev | cut -d ' ' -f 1 | rev | cut -d '.' -f 1)

        tmux rename-window $ssh_host
        command ssh $argv
        tmux set-window-option automatic-rename on 1>/dev/null
    else
        command ssh $argv
    end
end
