# Tgus wrapper supposed to preven Node-apps (that we run via yarn) from leaving "terminal garbage"
# after we terminate the processes. E.g., terminal escape codes after clicking inside the terminal.
function yarn --wraps yarn
    command yarn $argv
    set -l s $status
    printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1015l\e[?1004l'
    set -l saved (stty -g)
    stty -icanon -echo min 0 time 3   # 0.3s read timeout
    dd bs=1024 count=1 of=/dev/null 2>/dev/null
    stty $saved
    return $s
end
