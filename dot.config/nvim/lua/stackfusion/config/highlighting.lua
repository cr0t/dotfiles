local opts = {
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
}

require("nvim-treesitter.configs").setup(opts)
