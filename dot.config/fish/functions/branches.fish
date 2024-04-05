# This is a reworked (and enhanced) version of the original Ryan Bigg's one:
# https://github.com/radar/dot-files/blob/master/gitaliases#L42-L48
function branches --description="Quick fzf-switcher between the Git branches"
    # we can remove the ` | bat ...` if we do not have it installed and enjoy just colorless standard git diff output
    set --local fzf_preview_cmd 'git diff --no-color ...{} | bat --style numbers,changes --color always --line-range :256'

    set --local all_branches (git branch --all --no-color --sort=-committerdate --format='%(refname)')
    set --local chosen_full (string split ' ' $all_branches | fzf-tmux -p 80%,70% --no-multi --preview=$fzf_preview_cmd)
    set --local chosen_short (string split '/' $chosen_full)[-1]

    # git will automatically switch to the remote and track it if there is no local yet:
    # https://git-scm.com/docs/git-checkout#Documentation/git-checkout.txt-emgitcheckoutemltbranchgt
    git checkout $chosen_short
end
