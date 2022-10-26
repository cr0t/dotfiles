# Automatically load and add to SSH agent keys we need
switch (uname)
    case Linux
        # echo Hi Tux!
    case Darwin
        ssh-add --apple-load-keychain 2>&1 &>/dev/null
end
