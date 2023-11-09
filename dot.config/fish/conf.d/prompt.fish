# fish prompt inspired by RobbyRussel theme
# Uses __fish_git_prompt method

set normal (set_color normal)
set green (set_color -o green)
set blue (set_color -o blue)
set red (set_color -o red)

# https://github.com/fish-shell/fish-shell/blob/master/share/functions/fish_git_prompt.fish
set __fish_git_prompt_show_informative_status 'yes'
set __fish_git_prompt_char_stateseparator ' '
set __fish_git_prompt_char_dirtystate '+' # default plus symbol is too bold in Monaco typeface
set __fish_git_prompt_showcolorhints 'yes'
set __fish_git_prompt_color_branch red
set __fish_git_prompt_color_cleanstate green

function trimmed_git_prompt
    set --local git_prompt_max_length 48

    set --local prompt (__fish_git_prompt | tr -d '()')
    set --local pure_length (__pure_string_width $prompt)
    set --local colored_length (string length $prompt)
    set --local ffix_length (math --scale=0 (math $colored_length - $pure_length) / 2)
    set --local half_length (math --scale=0 $git_prompt_max_length / 2)
    set --local begin_ends_at (math $ffix_length + $half_length)
    set --local end_starts_at (math $colored_length - $ffix_length - $half_length)

    # This is for debug purposes:
    # printf "/PURE:%s" $pure_length
    # printf "/COLORED:%s" $colored_length
    # printf "/FFIX:%s" $ffix_length
    # printf "/HALF:%s" $half_length
    # printf "/BEGIN:%s" $begin_ends_at
    # printf "/END:%s" $end_starts_at

    if test $pure_length -gt $git_prompt_max_length
        set --local prompt_begin (string sub -s 1 -l $begin_ends_at $prompt)
        set --local prompt_end (string sub -s $end_starts_at $prompt)
        printf "%s…%s" $prompt_begin $prompt_end
    else
        printf "%s" $prompt
    end
end

function fish_prompt
    set -l last_status $status
    if test $last_status = 0
        set arrow "$green>"
    else
        set arrow "$red>"
    end

    set -l cwd $blue(basename (prompt_pwd))

    if [ (__fish_git_prompt) ]
        printf "$arrow $cwd$normal%s " (trimmed_git_prompt)
    else
        printf "$arrow $cwd "
    end

    set_color normal
end

function fish_right_prompt
  # intentionally left blank (disable default timestamp on the right side)
 end

### helpers

# https://github.com/rafaelrinaldi/pure/blob/master/functions/_pure_string_width.fish
function __pure_string_width
    echo (string length (string replace -ra '\e\[[^m]*m' '' $argv[1]))
end
