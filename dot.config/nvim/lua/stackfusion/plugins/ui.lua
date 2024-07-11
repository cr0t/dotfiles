return {
    -- Better `vim.notify()`
    {
        "rcarriga/nvim-notify",
        version = "*",
        opts = {
            stages = "static",
            timeout = 3000,
            max_height = function()
                return math.floor(vim.o.lines * 0.75)
            end,
            max_width = function()
                return math.floor(vim.o.columns * 0.75)
            end,
            on_open = function(win)
                vim.api.nvim_win_set_config(win, { zindex = 100 })
            end,
        }
    },

    -- Fancy-looking tabs, which include filetype icons, and re-ordering
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        event = "VeryLazy",
        opts = function()
            local bufferline = require("bufferline")

            local opts = {
                options = {
                    diagnostics = "nvim_lsp",
                    color_icons = false,
                    indicator = { style = "none" },
                    offsets = {
                        { filetype = "NvimTree", text = "Explorer" }
                    },
                    style_preset = {
                        bufferline.style_preset.no_italic,
                        bufferline.style_preset.no_bold
                    }
                }
            }

            return opts
        end
    },

    -- Fancy-looking statusline
    {
        "nvim-lualine/lualine.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        event = "VeryLazy",
        opts = function()
            local lualine_require = require("lualine_require")
            lualine_require.require = require

            local opts = {
                options = {
                    theme = "auto",
                    globalstatus = vim.o.laststatus == 3,
                    disabled_filetypes = {
                        statusline = { "ministarter" }
                    },
                },
                extensions = { "nvim-tree" }
            }

            return opts
        end
    },
}
