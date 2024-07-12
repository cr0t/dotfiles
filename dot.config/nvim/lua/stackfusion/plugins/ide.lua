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

    -- Elixir support for Vim/Neovim (e.g., provides syntax/elixir.vim)
    {
        "elixir-editors/vim-elixir",
        version = "*"
    },

    -- LSP servers + Autocompletion
    {
        "williamboman/mason.nvim",
        version = "*",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "neovim/nvim-lspconfig",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-vsnip",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "onsails/lspkind.nvim",
        },
        config = function(_, _opts)
            require("stackfusion.config.mason-lspconfig")
            require("stackfusion.config.autocompletion")
        end
    }
}
