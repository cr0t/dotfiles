set --local lo_sbin "/usr/local/sbin"
set --local littles "$HOME/.dotfiles/littles/"
set --local vs_code "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
set --local escripts "$HOME/.mix/escripts"

# Check if path exist and add it to the $PATH
set --local paths $lo_sbin $littles $vs_code $escripts

for path in $paths
    if test -d $path
        set -gx PATH $path $PATH
    end
end
