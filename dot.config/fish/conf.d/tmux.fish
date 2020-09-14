set normal (set_color normal)
set red (set_color -o red)

function tbase --description="Initiates a base tmux session (or attaches it)"
    # see if we are inside tmux session already
    if set -q TMUX
        printf "$red\e0Cannot make this happen: already in a tmux session\n$normal"
        return
    end

    # create or attach to a session named as current user
    tmux new -A -s "$USER"
end
