local cmp = require('cmp')
local lspkind = require('lspkind')

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true })
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp', priority = 8 },
    { name = 'nvim_lsp_signature_help', priority = 7 },
    { name = 'vsnip', priority = 6, keyword_length = 4 },
    { name = 'buffer', priority = 5, keyword_length = 4 },
    { name = 'path', priority = 4, keyword_length = 4 },
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      maxwidth = 50,
      ellipsis_char = '…',
      menu = ({
        nvim_lsp = '[LSP]',
        nvim_lsp_signature_help = '[LSP]',
        vsnip = '[VSnip]',
        buffer = '[Buffer]',
        path = '[Path]'
      })
    })
  },
  performance = {
    debounce = 5, -- default 60
    max_view_entries = 128, -- default 200
  },
})
