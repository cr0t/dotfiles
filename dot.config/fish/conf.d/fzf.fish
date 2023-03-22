# IMPORTANT: install bat, fd, fzf and fish key bindings to improve quality of your life with fzf
#
# - https://github.com/junegunn/fzf#installation
# - https://github.com/junegunn/fzf/blob/master/ADVANCED.md
# - https://andrew-quinn.me/fzf/

if type -q fd
  # use fd, plus set it to respect gitignore, ignore node_modules, show hidden files, and follow symbolic links
  set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git --exclude node_modules'
else
  set -gx FZF_DEFAULT_COMMAND 'find * -type f'
end

set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND

if type -q bat
  # a bit of styling
  set -g fzf_preview_command 'bat --style numbers,changes --color always --line-range :256 {}'
else
  set -g fzf_preview_command 'cat {}'
end

set -gx FZF_DEFAULT_OPTS "--height 70% --layout reverse --border --inline-info --preview '$fzf_preview_command'"

function fzp --description='Shortcut to run fzf with --preview option params'
    if type -q fzf
        fzf --preview "$fzf_preview_command"
    else
        echo "fzf is not available"
    end
end

function rgp --description='Shortcut to run rigpgrep in local directory and search in the output via fzf'
    if type -q rg
        rg . | fzf --no-preview | cut -d ":" -f 1
    else
        echo "rigpgrep is not available"
    end
end
