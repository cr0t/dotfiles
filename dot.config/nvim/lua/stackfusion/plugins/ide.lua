return {
  -- (Advanced) Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    version = "*",
    event = "VeryLazy",
    lazy = vim.fn.argc(-1) == 0,     -- load treesitter early when opening a file from the cmdline
    build = ":TSUpdate",
    config = function()
      require("stackfusion.config.highlighting")
    end
  },

  -- LSP servers + Autocompletion
  {
    "williamboman/mason.nvim",
    version = "*",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",                      -- suggests modules/functions
      "hrsh7th/cmp-buffer",                        -- suggests stuff from other opened buffers
      "hrsh7th/cmp-path",                          -- suggests filenames and paths from the current project
      "hrsh7th/cmp-nvim-lsp-signature-help",       -- shows function signature while typing arguments
      "onsails/lspkind.nvim",
    },
    config = function()
      require("stackfusion.config.lspconfig")
      require("stackfusion.config.diagnostics")
      require("stackfusion.config.autocompletion")
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
