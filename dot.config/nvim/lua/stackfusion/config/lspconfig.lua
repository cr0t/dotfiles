require('mason').setup()

-- Installed servers are enabled by mason-lspconfig (`automatic_enable`), including the ones installed later
require('mason-lspconfig').setup()

-- LSP servers to install on demand, the first time a file of this type is opened.
-- Once installed, a server attaches to all of its own filetypes (e.g. harper_ls also checks comments in code).
local servers_by_ft = {
  bash            = { 'bashls' },
  sh              = { 'bashls' },
  css             = { 'cssls', 'emmet_language_server' },
  scss            = { 'cssls', 'emmet_language_server' },
  less            = { 'cssls', 'emmet_language_server' },
  elm             = { 'elmls' },
  elixir          = { 'expert' },
  eelixir         = { 'expert' },
  heex            = { 'expert', 'emmet_language_server' },
  eruby           = { 'ruby_lsp', 'emmet_language_server' },
  gitcommit       = { 'harper_ls' },
  html            = { 'html', 'emmet_language_server' },
  javascript      = { 'ts_ls', 'eslint' },
  javascriptreact = { 'ts_ls', 'eslint', 'emmet_language_server' },
  typescript      = { 'ts_ls', 'eslint' },
  typescriptreact = { 'ts_ls', 'eslint', 'emmet_language_server' },
  json            = { 'jsonls' },
  jsonc           = { 'jsonls' },
  lua             = { 'lua_ls' },
  markdown        = { 'harper_ls' },
  ruby            = { 'ruby_lsp' },
  svelte          = { 'svelte', 'eslint', 'emmet_language_server' },
  yaml            = { 'yamlls' },
  ['yaml.ansible'] = { 'ansiblels' },
  zig             = { 'zls' },
}

local function install_server(server)
  local registry = require('mason-registry')
  local pkg_name = require('mason-lspconfig').get_mappings().lspconfig_to_package[server]

  if not pkg_name or not registry.has_package(pkg_name) then
    vim.notify(('Mason has no package for LSP server "%s"'):format(server), vim.log.levels.WARN)
    return
  end

  local pkg = registry.get_package(pkg_name)
  if pkg:is_installed() or pkg:is_installing() then
    return
  end

  vim.notify(('Installing %s…'):format(pkg_name))
  pkg:install({}, vim.schedule_wrap(function(success, err)
    if success then
      vim.notify(('Installed %s'):format(pkg_name))
    else
      vim.notify(('Failed to install %s: %s'):format(pkg_name, tostring(err)), vim.log.levels.ERROR)
    end
  end))
end

local function install_servers_for(filetype)
  local servers = servers_by_ft[filetype]
  if not servers then
    return
  end

  -- The registry has to be loaded first (e.g. on a fresh machine); it's a no-op while the cache is fresh
  require('mason-registry').refresh(vim.schedule_wrap(function()
    vim.tbl_map(install_server, servers)
  end))
end

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Installs missing LSP servers for the filetype through Mason',
  group = vim.api.nvim_create_augroup('UserLspInstall', {}),
  callback = function(args)
    install_servers_for(args.match)
  end,
})

-- Files opened from the command line may get their filetype before this file is loaded
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  if vim.api.nvim_buf_is_loaded(buf) then
    install_servers_for(vim.bo[buf].filetype)
  end
end

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
