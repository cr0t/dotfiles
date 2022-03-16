# During recent installation "from scratch" on a new laptop Homebrew installed in a new
# directory, and for some reason, my usual flow didn't work well.
#
# We have to explicitly evaluate shellenv for brew to get needed shell paths loaded.
#
# Snippet taken (and adapted for other envs) from https://github.com/Homebrew/brew/issues/10114
if status is-interactive
   and test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end
