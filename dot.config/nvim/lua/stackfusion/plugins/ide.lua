return {
    -- (Advanced) Syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        version = "*",
        event = "VeryLazy",
        lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
        build = ":TSUpdate",
        config = function(_, opts)
            require("stackfusion.config.highlighting")
        end
    },

    -- LSP servers + Autocompletion
    {
        "williamboman/mason.nvim",
        version = "*",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "neovim/nvim-lspconfig",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",                -- suggests modules/functions
            "hrsh7th/cmp-buffer",                  -- suggests stuff from other opened buffers
            "hrsh7th/cmp-path",                    -- suggests filenames and paths from the current project
            "hrsh7th/cmp-nvim-lsp-signature-help", -- shows function signature while typing arguments
            "onsails/lspkind.nvim",
        },
        config = function(_, _opts)
            require("stackfusion.config.mason-lspconfig")
            require("stackfusion.config.autocompletion")
        end
    }
}
