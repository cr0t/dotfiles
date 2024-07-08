return {
    {
        "echasnovski/mini.nvim",
        version = false,
        config = function()
            -- Check out these resources to make something cool:
            -- https://texteditor.com/ascii-art/ or https://texteditor.com/multiline-text-art/
            local logo = table.concat({
                ".▄▄ · ▄▄▄▄▄▄ ▄▄▄·  ▄▄· ▄ •▄ ·▄▄▄▄• ▄▌.▄▄ · ▪         ▐ ▄ ",
                "▐█ ▀. ▀•██ ▀▐█ ▀█ ▐█ ▌▪█▌▄▌▪█  ·█▪██▌▐█ ▀. ██  ▄█▀▄ •█▌▐█",
                "▄▀▀▀█▄  ▐█.▪▄█▀▀█ ██ ▄▄▐▀▀▄·█▀▀▪█▌▐█▌▄▀▀▀█▄▐█·▐█▌.▐▌▐█▐▐▌",
                "▐█▄▪▐█  ▐█▌·▐█▪ ▐▌▐███▌▐█.█▌██ .▐█▄█▌▐█▄▪▐█▐█▌▐█▌.▐▌██▐█▌",
                " ▀▀▀▀   ▀▀▀  ▀  ▀ ·▀▀▀ ·▀  ▀▀▀▀  ▀▀▀  ▀▀▀▀ ▀▀▀ ▀█▄▀▪▀▀ █▪",
            }, "\n")

            require("mini.comment").setup()
            require("mini.starter").setup({
                header = logo
            })
            require("mini.statusline").setup()
            require("mini.pairs").setup()
            require("mini.tabline").setup()
            require("mini.trailspace").setup({
                only_in_normal_buffers = true
            })
        end
    },
}
