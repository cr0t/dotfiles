# IMPORTANT: don't forget to install bat, fd, fzf and fish key bindings;
# see https://github.com/junegunn/fzf#installation

# use fd that will respect gitignore, ignore node_modules and show hidden files and follow symbolic links
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git --exclude node_modules'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND

# a bit of styling
#set -g fzf_preview_command 'file {}' # prints name and type of selected file
set -g fzf_preview_command 'bat --style numbers --color always --line-range :256 {}'
set -gx FZF_DEFAULT_OPTS "--height 50% --layout reverse --border --inline-info --preview '$fzf_preview_command'"

function fzfpreview --description='Shortcut to run fzf with --preview option params'
    fzf --preview "$fzf_preview_command"
end
