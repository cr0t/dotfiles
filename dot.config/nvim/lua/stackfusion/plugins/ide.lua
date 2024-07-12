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
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
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
            -- LSP servers configurations

            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "ansiblels", "bashls", "cssls", "elixirls", "elmls", "html", "lua_ls", "solargraph", "svelte",
                    "tsserver", "yamlls"
                },
            })

            require("mason-lspconfig").setup_handlers({
                -- The first entry (without a key) will be the default handler and will be called for each installed
                -- server that doesn't have a dedicated handler.
                function(server_name)
                    require("lspconfig")[server_name].setup {
                        capabilities = require("cmp_nvim_lsp").default_capabilities()
                    }
                end,
                -- Next, you can provide a dedicated handler for specific servers. For example, a handler override for
                -- the `lua_ls`:
                ["lua_ls"] = function()
                    require("lspconfig").lua_ls.setup({
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim" }
                                }
                            }
                        }
                    })
                end,
            })

            -- Autocompletion source and preview

            local cmp = require("cmp")
            local lspkind = require("lspkind")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        vim.snippet.expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<cr>"] = cmp.mapping.confirm({ select = true })
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp",                priority = 8 },
                    { name = "nvim_lsp_signature_help", priority = 7 },
                    { name = "vsnip",                   priority = 6, keyword_length = 4 },
                    { name = "buffer",                  priority = 5, keyword_length = 4 },
                    { name = "path",                    priority = 4, keyword_length = 4 },
                }),
                formatting = {
                    format = lspkind.cmp_format({
                        mode = "symbol_text",
                        maxwidth = 50,
                        ellipsis_char = "…",
                        menu = ({
                            nvim_lsp = "[LSP]",
                            nvim_lsp_signature_help = "[LSP]",
                            buffer = "[Buffer]",
                            path = "[Path]"
                        })
                    })
                },
                performance = {
                    debounce = 5,           -- default 60
                    max_view_entries = 100, -- default 200
                },
            })
        end
    }
}
