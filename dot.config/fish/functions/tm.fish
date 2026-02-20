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

    # lets build a session name (or use default <hostname> template)
    set --local session_name

    if count $argv > /dev/null
        set session_name (string join '-' $argv)
    else
        # WARNING: hostname sometimes might be quite long (e.g., when using corporate VPN)
        set session_name (hostname -s | string lower)
    end

    # truncate prefix to 32 chars max
    if test (string length $session_name) -gt 30
        set session_name (string sub -l 28 $session_name)…
    end

    # tmux doesn't allow us to use dots (could appear in the hostname) in the session name
    set session_name (string replace --all '.' '-' $session_name)

    # create new session (detached - in case we're inside another tmux session now)
    if not tmux has-session -t $session_name
        tmux new-session -d -s $session_name
    end

    # find a way how to connect to the session: switch to existing or attach to newly created
    if set -q TMUX
        tmux switch-client -t $session_name
    else
        tmux attach-session -t $session_name
    end
end
