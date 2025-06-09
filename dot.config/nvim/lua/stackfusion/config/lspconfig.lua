require('mason').setup()

require('mason-lspconfig').setup({
  ensure_installed = {
    'ansiblels', 'bashls', 'cssls', 'elixirls', 'elmls', 'emmet_language_server', 'harper_ls',
    'html', 'lua_ls', 'ruby_lsp', 'svelte', 'ts_ls', 'yamlls', 'zls'
  },
})

vim.lsp.config('emmet_language_server', {
  filetypes = {
    'css', 'elixir', 'eruby', 'heex', 'html', 'javascriptreact', 'less', 'pug', 'sass', 'scss',
    'svelte', 'typescriptreact', 'vue'
  }
})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      },
      telemetry = {
        enable = false
      }
    }
  }
})
