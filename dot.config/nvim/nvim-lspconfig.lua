local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- See more information about Elixir LS itself (capabilities, settings, etc.) here:
-- https://github.com/elixir-lsp/elixir-ls/blob/master/apps/language_server/lib/language_server/server.ex
lspconfig.elixirls.setup {
  cmd = { vim.fn.expand('~/.local/lsp/elixir-ls/language_server.sh') },
  capabilities = capabilities,
  settings = {
    elixirLS = {
      -- Below is the list of available options (as on 2023.03.25) and their
      -- default values; they are searchable by the link above:
      --
      -- additionalWatchedExtensions = []
      -- autoBuild = true
      -- dialyzerEnabled = true,
      -- dialyzerFormat = 'dialyxir_long'
      -- dialyzerWarnOpts = []
      -- enableTestLenses = false
      -- envVariables = <undefined>
      -- fetchDeps = false
      -- mixEnv = 'test'
      -- mixTarget = <undefined>
      -- projectDir = <undefined>
      -- signatureAfterComplete = true
      -- suggestSpecs = <undefined>
    }
  }
}
