return {
    -- A simple and easy way to use the interface for tree-sitter
    {
        "nvim-treesitter/nvim-treesitter",
        version = "*",
        build = ":TSUpdate",
        config = function()
            -- Use nvim-treesitter only if gcc is available (not a production server, for example)
            if vim.fn.executable("gcc") == 1 then
                require("nvim-treesitter.configs").setup {
                    ensure_installed = {
                        "bash", "elixir", "erlang", "fish", "heex", "html", "javascript", "lua", "markdown",
                        "markdown_inline", "ruby", "svelte", "typescript", "vim", "vimdoc"
                    },
                    auto_install = false, -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
                    highlight = {
                        additional_vim_regex_highlighting = true,
                        enable = true,
                        disable = function(_lang, buf)
                            local max_filesize = 100 * 1024 -- 100 KB
                            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))

                            if ok and stats and stats.size > max_filesize then
                                return true
                            end
                        end,
                    }
                }
            end
        end
    },

    -- Autocompletion
    {
        "hrsh7th/nvim-cmp",
        version = "*",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-nvim-lsp",
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'hrsh7th/cmp-nvim-lua',
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-vsnip",
            "hrsh7th/vim-vsnip",
            "onsails/lspkind.nvim",
        },
        config = function()
            local cmp = require("cmp")
            local lspkind = require("lspkind")

            cmp.setup {
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end,
                },

                -- Mappings for cmp
                mapping = {
                    -- Autocompletion menu
                    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i" }),
                    ["<CR>"] = cmp.config.disable,                      -- Turn off autocomplete on <CR>
                    ["<C-y>"] = cmp.mapping.confirm({ select = true }), -- Turn on autocomplete on <C-y>

                    -- Use <C-e> to abort autocomplete
                    ["<C-e>"] = cmp.mapping({
                        i = cmp.mapping.abort(), -- Abort completion
                        c = cmp.mapping.close(), -- Close completion windoselect_prev_itemw
                    }),

                    -- Use <C-p> and <C-n> to navigate through completion variants
                    ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
                    ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
                },

                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "nvim_lsp_signature_help" },
                    { name = "nvim_lua" },
                    { name = "vsnip",                  keyword_length = 4 },
                    { name = "buffer",                 keyword_length = 4 },
                    { name = "path",                   keyword_length = 4 },
                }),
                formatting = {
                    format = lspkind.cmp_format({
                        mode = "symbol_text",
                        maxwidth = 50,
                        ellipsis_char = "…",
                        menu = ({
                            nvim_lsp = "[LSP]",
                            nvim_lsp_signature_help = "[LSP]",
                            vsnip = "[VSnip]",
                            buffer = "[Buffer]",
                            path = "[Path]"
                        })
                    })
                },
                performance = {
                    debounce = 5,           -- default 60
                    max_view_entries = 100, -- default 200
                },
            }
        end
    },

    -- Nice symbolic icons in the suggestions box
    -- { "onsails/lspkind.nvim", version = "*" },
    -- VSCode(LSP)'s snippet feature in vim/nvim
    -- { "hrsh7th/vim-vsnip",    version = "*" },
    -- Autocompletion
    -- 1. { "hrsh7th/nvim-cmp",                    version = "*" },
    -- nvim-cmp's source for built-in LSP client
    -- 2. { "hrsh7th/cmp-nvim-lsp",                version = "*" },
    -- nvim-cmp's source for opened buffers
    -- { "hrsh7th/cmp-buffer",   version = "*" },
    -- nvim-cmp's source for vim-vsnip
    -- { "hrsh7th/cmp-vsnip",    version = "*" },
    -- nvim-cmp's source for filesystem paths
    -- 3. { "hrsh7th/cmp-path",                    version = "*" },
    -- nvim-cmp's extra helper
    -- 4. { "hrsh7th/cmp-nvim-lsp-signature-help", version = "*" }
}
