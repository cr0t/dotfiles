set --local lo_sbin "/usr/local/sbin"
set --local littles "$HOME/.dotfiles/littles/"
set --local vs_code "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
set --local escripts "$HOME/.mix/escripts"
set --local lo_bin "$HOME/.local/bin"

# Check if path exist and add it to the $PATH
set --local paths $lo_sbin $littles $vs_code $escripts $lo_bin

for path in $paths
    if test -d $path
        # Docs: https://fishshell.com/docs/current/cmds/fish_add_path.html
        fish_add_path --path $path
    end
end
