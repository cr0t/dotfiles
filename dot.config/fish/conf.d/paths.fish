set --local lo_sbin "/usr/local/sbin"
set --local littles "$HOME/.dotfiles/littles/"
set --local vs_code "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
set --local escripts "$HOME/.mix/escripts"
set --local lo_bin "$HOME/.local/bin"
set --local wordnet "$HOME/.vim/bundle/fzf-wordnet.vim/bin"

# Check if path exist and add it to the $PATH
set --local paths $lo_sbin $littles $vs_code $escripts $lo_bin $wordnet

for path in $paths
    if test -d $path
        set -gx PATH $path $PATH
    end
end
