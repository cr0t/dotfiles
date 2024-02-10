set -gx ERL_AFLAGS "-kernel shell_history enabled"

# next two used to build Erlang (with asdf install erlang ..., for example)
set -gx KERL_BUILD_DOCS "yes"
set -gx KERL_CONFIGURE_OPTIONS "--without-javac"
