# macOS has broken whatis database (quick search for man pages). That leads to
# pauses when we run some commands. A better solution should be done in fish
# version 3.2.0, and for now we can use only this workaround
#
# See more about the issue here:
# https://github.com/fish-shell/fish-shell/issues/6270
# https://github.com/fish-shell/fish-shell/pull/7365
# https://github.com/fish-shell/fish-shell/issues/6585#issuecomment-754526556

function __fish_describe_command
end

funcsave __fish_describe_command
