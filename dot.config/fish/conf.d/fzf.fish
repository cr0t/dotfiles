# IMPORTANT: don't forget to install fzf and fish key bindings! See https://github.com/junegunn/fzf#installation

# use fd that will respect gitignore, ignore node_modules and show hidden files and follow symbolic links
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git --exclude node_modules'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND

function fzfpreview --description="Shortcut to run fzf with --preview option params"
    fzf --preview "bat --style=numbers --color=always --line-range :500 {}"
end
