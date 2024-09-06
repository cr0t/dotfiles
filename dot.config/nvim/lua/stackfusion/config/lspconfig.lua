require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "ansiblels", "bashls", "cssls", "elixirls", "elmls", "html", "lua_ls", "solargraph", "svelte", "tsserver", "yamlls"
  },
})

require("mason-lspconfig").setup_handlers({
  -- The first entry (without a key) will be the default handler and will be called for each installed server that
  -- doesn't have a dedicated handler.
  function(server_name)
    -- tsserver renamed to ts_ls: https://github.com/neovim/nvim-lspconfig/pull/3232
    if server_name == "tsserver" then
      server_name = "ts_ls"
    end

    require("lspconfig")[server_name].setup {
      capabilities = require("cmp_nvim_lsp").default_capabilities()
    }
  end,
  -- Next, you can provide a dedicated handler for specific servers. For example, a handler override for the `lua_ls`:
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
