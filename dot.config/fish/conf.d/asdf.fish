if type -q brew
    # macOS
    if test -f (brew --prefix asdf)"/libexec/asdf.fish"
        source (brew --prefix asdf)"/libexec/asdf.fish"
    end
else
    # Ubuntu
    if test -f ~/.asdf/asdf.fish
      source ~/.asdf/asdf.fish
    end
end
