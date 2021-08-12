# use fd that will respect gitignore and show hidden filesm and follow symbolic links
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'

function fzf-preview --description="Shortcut to run fzf with --preview option params"
    fzf --preview "bat --style=numbers --color=always --line-range :500 {}"
end
