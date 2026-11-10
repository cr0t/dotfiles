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
    opts = {
      options = {
        theme = "auto",
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = {
          statusline = { "starter" }
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename", "lsp_status" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" }
      },
      extensions = { "nvim-tree" }
    }
  },

  -- From LazyVim: highly experimental plugin that completely replaces the UI for messages, cmdline and the popupmenu.
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
    keys = {
      { "<leader>sn",  "",                                                            desc = "+noice" },
      { "<S-Enter>",   function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c",                              desc = "Redirect Cmdline" },
      { "<leader>snl", function() require("noice").cmd("last") end,                   desc = "Noice Last Message" },
      { "<leader>snh", function() require("noice").cmd("history") end,                desc = "Noice History" },
      { "<leader>sna", function() require("noice").cmd("all") end,                    desc = "Noice All" },
      { "<leader>snd", function() require("noice").cmd("dismiss") end,                desc = "Dismiss All" },
      { "<leader>snt", function() require("noice").cmd("pick") end,                   desc = "Noice Picker (Telescope/FzfLua)" },
    },
    config = function(_, opts)
      -- HACK: noice shows messages from before it was enabled,
      -- but this is not ideal when Lazy is installing plugins,
      -- so clear the messages in this case.
      if vim.o.filetype == "lazy" then
        vim.cmd([[messages clear]])
      end
      require("noice").setup(opts)
    end,
  },

  -- Extra UI/UX stuff
  { "folke/which-key.nvim",  version = "*", event = "VeryLazy" },
  { "echasnovski/mini.nvim", version = "*", event = "VeryLazy" },
  { "szw/vim-maximizer",     version = "*", event = "VeryLazy" }
}
