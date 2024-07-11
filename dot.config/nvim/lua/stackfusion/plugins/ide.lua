return {
    -- (Advanced) Syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        version = "*",
        event = "VeryLazy",
        lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
        build = function()
            require("nvim-treesitter.install").update({ with_sync = true })()
        end,
        opts = {
            ensure_installed = {
                "bash", "c", "diff", "elixir", "erlang", "fish", "heex", "html", "javascript", "jsdoc", "json", "jsonc",
                "lua", "luadoc", "luap", "markdown", "markdown_inline", "python", "query", "regex", "ruby", "svelte",
                "toml", "tsx", "typescript", "vim", "vimdoc", "xml", "yaml"
            },
            auto_install = false, -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
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
    }
}
