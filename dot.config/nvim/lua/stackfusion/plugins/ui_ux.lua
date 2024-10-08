return {
  -- Color themes
  { "EdenEast/nightfox.nvim" },

  -- Fancy-looking tabs, which include filetype icons, and re-ordering
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = { "BufReadPre", "BufNewFile" },
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
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
            statusline = { "starter" }
          },
        },
        extensions = { "nvim-tree" }
      }

      return opts
    end
  },

  -- Extra UI/UX stuff
  { "folke/which-key.nvim",  version = "*", event = "VeryLazy" },
  { "echasnovski/mini.nvim", version = "*", event = "VeryLazy" },
  { "szw/vim-maximizer",     version = "*", event = "VeryLazy" }
}
