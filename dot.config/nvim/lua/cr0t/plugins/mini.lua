return {
    {
        "echasnovski/mini.nvim",
        version = false,
        config = function()
            require("mini.statusline").setup()
            require("mini.comment").setup()
            require("mini.pairs").setup()
            require("mini.tabline").setup()
            require("mini.trailspace").setup({
                only_in_normal_buffers = true
            })
        end
    },
}
