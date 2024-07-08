return {
    {
        'romgrk/barbar.nvim',
        version = "*",
        dependencies = {
            'lewis6991/gitsigns.nvim',
            'nvim-tree/nvim-web-devicons',
        },
        init = function() vim.g.barbar_auto_setup = false end,
        opts = {
            animation = false,
            focus_on_close = 'previous',
            icons = {
                inactive = {
                    separator = {
                        left = "",
                        right = ""
                    }
                }
            },
            maximum_padding = 2,
            no_name_title = "[Untitled]",
            sidebar_filetypes = {
                NvimTree = true
            },
        }
    }
}
