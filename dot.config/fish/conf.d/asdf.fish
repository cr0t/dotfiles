# ASDF can be installed to the user's home directory (like in Ubuntu), or
# system-wide (like via Homebrew in macOS). We want to detect the way it was
# installed and load it accordingly.
#
# NOTE: `brew` must be available in $PATH, so ensure to set it before.

if not set -q ASDF_DIR
    if test -e ~/.asdf/asdf.fish
        source ~/.asdf/asdf.fish
    else if command -q brew
        source (brew --prefix asdf)"/libexec/asdf.fish"
    end
end
