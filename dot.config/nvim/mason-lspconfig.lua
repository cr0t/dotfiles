require("mason").setup()
require("mason-lspconfig").setup()

-- Diagnostics
-- -----------
--
-- Show diagnostics warnings automatically by hover in a floating window, we
-- used this guide initially, but had to rework it:
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#show-line-diagnostics-automatically-in-hover-window

-- vim.o.updatetime = 200 -- moved this to ~/.vimrc, but left here as a reminder
vim.diagnostic.config({ virtual_text = false })
vim.cmd([[ autocmd ColorScheme * highlight NormalFloat guibg=none ]])
vim.api.nvim_create_autocmd("CursorHold", {
  desc = "Shows diagnostics floating window in normal mode when cursor holds on a line with an issue",
  callback = function()
    local opts = {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = "single",
      source = "if_many",
      -- scope = "cursor", -- the default "line" works fine for our needs
    }

    vim.diagnostic.open_float(nil, opts)
  end
})

-- Key Mappings
-- ------------

-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys after the language
-- server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    -- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }

    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gK', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gk', vim.lsp.buf.signature_help, opts)
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
    vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
  end,
})

-- Language Servers
-- ----------------
--
-- Mason's Automatic Server Setup
--
-- See `:help mason-lspconfig-automatic-server-setup` for more details

require("mason-lspconfig").setup_handlers {
  -- The first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler.
  function(server_name)  -- default handler (optional)
    require("lspconfig")[server_name].setup {
      capabilities = require("cmp_nvim_lsp").default_capabilities()
    }
  end,
  -- Next, you can provide a dedicated handler for specific servers.
  -- For example, a handler override for the `rust_analyzer`:
  -- ["rust_analyzer"] = function ()
  --   require("rust-tools").setup {}
  -- end,
  ["lua_ls"] = function ()
    require("lspconfig").lua_ls.setup {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" }
          }
        }
      }
    }
  end,
}

-- (DEPRECATED) Manual Configuration of LSPConfig
-- ---------------------------------
--
-- See docs via `:help lspconfig-all` command
--
-- ...leaving it here for a while to check is Mason's automatic setup covers
-- our needs

-- local lspconfig = require("lspconfig")
--
-- lspconfig.lua_ls.setup {
--   settings = {
--     Lua = {
--       diagnostics = {
--         globals = { "vim" }
--       }
--     }
--   }
-- }
--
-- lspconfig.elixirls.setup {
--   capabilities = require('cmp_nvim_lsp').default_capabilities()
-- }
-- lspconfig.solargraph.setup {}
-- lspconfig.tsserver.setup {}
