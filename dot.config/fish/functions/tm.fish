# Usage examples:
#
# - tm                   # opens (or switches to) default session
# - tm ls                # list existing tmux sessions
# - tm blog              # opens (or switches to) the 'blog' session
# - tm my pet project    # opens (...) the 'my-pet-project' session
function tm --description="Simplified tmux session manager"
    if contains 'ls' $argv
        tmux list-sessions
        return
    end

    # TODO: add tbase rm <session>
    # if test $argv[1] = "rm"
    #     # ...
    #     return
    # end

    set --local session_name

    # lets build a session name (or use default '<name>[at]<os_type>' template)
    if count $argv > /dev/null
        set session_name (string join '-' $argv)
    else
        # unfortunately, hostname is not a reliable source when using OpenVPN
        # set --local host (hostname | string split '.')[1]
        set --local os_type (uname | string lower)
        set session_name (string join '[at]' $USER $os_type)
    end

    # tmux doesn't allow us to use dots in a session name
    set session_name (string replace --all '.' '-' $session_name)

    # create new session (detached - in case we're inside another tmux session now)
    if not tmux has-session -t $session_name
        tmux new-session -d -s $session_name
    end

    # find a way how to connect to the session
    if set -q TMUX
        tmux switch-client -t $session_name
    else
        tmux attach-session -t $session_name
    end
end
