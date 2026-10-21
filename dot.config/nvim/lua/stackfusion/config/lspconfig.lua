require('mason').setup()

require('mason-lspconfig').setup({
  ensure_installed = {
    'ansiblels', 'bashls', 'cssls', 'elmls', 'emmet_language_server', 'eslint', 'expert', 'harper_ls',
    'html', 'jsonls', 'lua_ls', 'ruby_lsp', 'svelte', 'ts_ls', 'yamlls', 'zls'
  },
})

-- Resolve each workspace's own eslint.config.mjs in monorepos
vim.lsp.config('eslint', {
  settings = {
    workingDirectory = { mode = 'auto' }
  }
})

vim.lsp.config('jsonls', {
  settings = {
    json = {
      schemas = require('schemastore').json.schemas(),
      validate = { enable = true }
    }
  }
})

vim.lsp.config('emmet_language_server', {
  filetypes = {
    'css', 'eruby', 'heex', 'html', 'javascriptreact', 'less', 'pug', 'sass', 'scss',
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

vim.lsp.config('harper_ls', {
  settings = {
    ['harper-ls'] = {
      linters = {
        LongSentences = false
      }
    }
  }
})
