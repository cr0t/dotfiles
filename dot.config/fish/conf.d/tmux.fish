set normal (set_color normal)
set red (set_color -o red)

function tbase --description="Initiates a base tmux session (or attaches it)"
    # see if we are inside tmux session already
    if set -q TMUX
        printf "$red\e0Cannot make this happen: already in a tmux session\n$normal"
        return
    end

    # tmux doesn't allow us to use dots in session name
    set --local user (string replace --all '.' '-' $USER)
    set --local host (hostname | string split '.')[1]
    set --local session_name (string join '[at]' $user $host)

    # create or attach to a session
    tmux new -A -s $session_name
end
