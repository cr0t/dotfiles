if type -q brew
    if test -f (brew --prefix asdf)"/asdf.fish"
        source (brew --prefix asdf)"/asdf.fish"
    end
end
