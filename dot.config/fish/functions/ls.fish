function ls --description="In-line replacement for eza or fallback to ls"
    if command -q eza
        command eza --icons $argv
    else
        command ls $argv
    end
end
