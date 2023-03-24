local lspconfig = require('lspconfig')

lspconfig.elixirls.setup {
  cmd = { vim.fn.expand('~/.local/lsp/elixir-ls/language_server.sh') },
  --capabilities = capabilities,
  settings = {
    elixirLS = {
      dialyzerEnabled = true,
    }
  }
}
