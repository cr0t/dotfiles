local wk = require("which-key")
local mini_map = require("mini.map")
local mini_trail = require("mini.trailspace")

local function trim_whitespace()
  mini_trail.trim()
  mini_trail.trim_last_lines()
end

local function format_buffer()
  vim.lsp.buf.format({ async = true })
end

wk.add({
  -- Foremost, provide descriptions to Vim's shortcuts (we set in vimrc.keymap)
  { "<leader>q", desc = "Close buffer" },
  { "<leader>w", desc = "Close window" },
  { "<leader>l", desc = "Toggle invisibles" },
  { "<leader>n", desc = "Hide search highlight" },

  -- Diagnostics list (in the Telescope)
  { "<leader>d", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },

  -- Some special "bufferline.nvim" treatments
  { "<leader>]", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
  { "<leader>[", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
  { "<C-]>",     "<cmd>BufferLineMoveNext<cr>",  desc = "Move next" },
  { "<C-[>",     "<cmd>BufferLineMovePrev<cr>",  desc = "Move prev" },

  -- Now it's time to add some extra - Neovim-related only
  { "<leader>m", mini_map.toggle,                desc = "Toggle mini-map" },
  { "<leader>t", trim_whitespace,                desc = "Trim whitespace" },
  { "<C-w>z",    "<cmd>MaximizerToggle<cr>",     desc = "Maximize window" },
})

-- IDE-/LSP-ish
-- See `:help vim.lsp.*` for documentation on any of the below functions
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(event)
    wk.add({
      { "<space>f", format_buffer,              desc = "Format file",            buffer = event.buf },
      { "gD",       vim.lsp.buf.declaration,    desc = "Go to Declaration",      buffer = event.buf },
      { "gd",       vim.lsp.buf.definition,     desc = "Go to Definition",       buffer = event.buf },
      { "gK",       vim.lsp.buf.hover,          desc = "Show info under cursor", buffer = event.buf },
      { "gk",       vim.lsp.buf.signature_help, desc = "Signature help",         buffer = event.buf }
    })

    -- Below is stuff that I don't use (yet):
    --
    -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    -- vim.keymap.set('n', '<space>d', vim.lsp.buf.type_definition, opts)
    -- vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    -- vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
    -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    -- vim.keymap.set('n', '<space>wl', function()
    --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, opts)
  end,
})
