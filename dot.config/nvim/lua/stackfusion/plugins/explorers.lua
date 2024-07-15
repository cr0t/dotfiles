return {
  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    keys = {
      { "<C-b>", "<cmd>NvimTreeToggle<cr>",   desc = "Open Explorer" },
      { "<C-f>", "<cmd>NvimTreeFindFile<cr>", desc = "Reveal in Explorer" }
    },
    opts = {
      view = {
        width = 40
      }
    }
  },

  -- File fuzzy-finder
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = "nvim-lua/plenary.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>p", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>f", "<cmd>Telescope live_grep<cr>",  desc = "Fuzzy-finder" }
    },
    opts = function()
      -- The following Telescope settings configures it to layout similar to this:
      --
      -- ┌────────────────────────────────────────────────┐
      -- │   ┌───────────────────┐┌──────Filepath─────┐   │
      -- │   │> Prompt           ││                   │   │
      -- │   └───────────────────┘│                   │   │
      -- │   ┌───────────────────┐│                   │   │
      -- │   │  Results          ││      Preview      │   │
      -- │   │  Results          ││                   │   │
      -- │   │  ...              ││                   │   │
      -- │   │                   ││                   │   │
      -- │   └───────────────────┘└───────────────────┘   │
      -- └────────────────────────────────────────────────┘

      local telescope_actions = require("telescope.actions")

      local opts = {
        defaults = {
          dynamic_preview_title = true,
          layout_strategy = "flex",
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
          mappings = {
            i = { ["<esc>"] = telescope_actions.close } -- press ESC once to close the modal
          },
          winblend = 5,                                 -- pseudo-transparency for the modal (0..100)
          preview = {
            treesitter = false
          }
        },
      }

      return opts
    end
  }
}
