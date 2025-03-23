function bw-session --description="Start Bitwarden CLI session, lock it manually!"
    set -xU BW_SESSION (bw unlock --raw)
    echo -e "\033[0;33mWARNING: Do not forget to lock it manually, using the `bw lock` command!\033[0m"
end
