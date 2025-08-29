return {
  -- (Advanced) Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    build = ":TSUpdate",
    config = function()
      require("stackfusion.config.highlighting")
    end
  },

  {
    'saghen/blink.cmp',
    version = '1.*',
    opts = {
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      keymap = {
        preset = 'enter'
      },
      completion = {
        documentation = { auto_show = true }
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' }
      },
    },
    opts_extend = { "sources.default" }
  },

  -- LSP servers + Autocompletion
  {
    "williamboman/mason.nvim",
    version = "*",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "onsails/lspkind.nvim",
    },
    config = function()
      require("stackfusion.config.lspconfig")
      require("stackfusion.config.diagnostics")
    end
  },

  -- Code outline
  {
    "stevearc/aerial.nvim",
    version = "*",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("stackfusion.config.outline")
    end
  },

  -- Git-stuff
  { "tpope/vim-fugitive", version = "*", event = "VeryLazy" },
  {
    "lewis6991/gitsigns.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("gitsigns").setup()
    end
  }
}
