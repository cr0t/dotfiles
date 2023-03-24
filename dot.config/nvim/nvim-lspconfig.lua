local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig.elixirls.setup {
  cmd = { vim.fn.expand('~/.local/lsp/elixir-ls/language_server.sh') },
  capabilities = capabilities,
  settings = {
    elixirLS = {
      dialyzerEnabled = true,
    }
  }
}
