# fish prompt inspired by RobbyRussel theme
# Uses __fish_git_prompt method

set normal (set_color normal)
set green (set_color -o green)
set blue (set_color -o blue)
set red (set_color -o red)

# https://github.com/fish-shell/fish-shell/blob/master/share/functions/__fish_git_prompt.fish
set __fish_git_prompt_show_informative_status 'yes'
set __fish_git_prompt_char_stateseparator ' '
set __fish_git_prompt_char_dirtystate '+' # default plus symbol is too bold in Monaco typeface
set __fish_git_prompt_showcolorhints 'yes'
set __fish_git_prompt_color_branch red
set __fish_git_prompt_color_cleanstate green

function fish_prompt
  set -l last_status $status
  if test $last_status = 0
    set arrow "$green>"
  else
    set arrow "$red>"
  end

  set -l cwd $blue(basename (prompt_pwd))

  if [ (__fish_git_prompt) ]
    printf "$arrow $cwd$normal%s " (__fish_git_prompt | tr -d '()')
  else
    printf "$arrow $cwd "
  end

  set_color normal
end
