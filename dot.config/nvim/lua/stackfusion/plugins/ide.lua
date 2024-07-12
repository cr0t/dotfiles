return {
    -- (Advanced) Syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        version = "*",
        event = "VeryLazy",
        lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
        build = ":TSUpdate",
        opts = {
            auto_install = vim.fn.executable "git" == 1 and vim.fn.executable "tree-sitter" == 1, -- only when git and tree-sitter available
            ensure_installed = {
                "bash", "c", "diff", "elixir", "erlang", "fish", "heex", "html", "javascript", "jsdoc", "json", "jsonc",
                "lua", "luadoc", "luap", "markdown", "markdown_inline", "python", "query", "regex", "ruby", "svelte",
                "toml", "tsx", "typescript", "vim", "vimdoc", "xml", "yaml"
            },
            highlight = {
                enable = true,
                disable = function(_lang, bufnr)
                    return vim.api.nvim_buf_line_count(bufnr) > 50000
                end,
            },
            indent = { enable = true }
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end
    },

    {
        "williamboman/mason.nvim",
        version = "*",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "neovim/nvim-lspconfig"
        },
        config = function(_, _opts)
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "elixirls", "lua_ls" },
            })

            require("lspconfig").lua_ls.setup({})
            require("lspconfig").elixirls.setup({})
        end
    }
}
