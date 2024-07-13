-- Check out these resources to make nice and cool logos:
-- https://texteditor.com/ascii-art/ or https://texteditor.com/multiline-text-art/
local logo = table.concat({
    "░▒█▀▀▀█░▀█▀░█▀▀▄░█▀▄░█░▄░▒█▀▀▀░█░▒█░█▀▀░░▀░░▄▀▀▄░█▀▀▄",
    "░░▀▀▀▄▄░░█░░█▄▄█░█░░░█▀▄░▒█▀▀░░█░▒█░▀▀▄░░█▀░█░░█░█░▒█",
    "░▒█▄▄▄█░░▀░░▀░░▀░▀▀▀░▀░▀░▒█░░░░░▀▀▀░▀▀▀░▀▀▀░░▀▀░░▀░░▀",
}, "\n")

require("mini.starter").setup({
    header = logo
})

require("mini.comment").setup() -- use `gc` to comment selected lines

require("mini.map").setup()

require("mini.sessions").setup({
    autoread = true,
    hooks = {
        pre = {
            write = function()
                vim.api.nvim_exec_autocmds("User", { pattern = "SessionSavePre" })
            end,
        },
    },
})

require("mini.trailspace").setup({
    only_in_normal_buffers = true
})
