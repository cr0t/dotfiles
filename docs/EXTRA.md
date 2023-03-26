# Extra Notes

## Vale Spellchecker

Download and install `vale`'s configured styles with `vale sync` command. Run it from home directory after linking all the configuration files.

## Copy and Update `.gitconfig.local`

After setting up these files, you'll see `.gitconfig.local.example` one that is
created in the home directory. You need to check what it contains and update if
needed.

```console
cp ~/.gitconfig.local.example ~/.gitconfig.local
```

## How to Use [tmux plugins](https://github.com/tmux-plugins)

Please install `tpm` before you can use tmux plugins:

```console
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### `nvim-lspconfig` ElixirLS Options

As far as I understood (and tested in my setup), we do not have to provide all
(or even some) the settings to `lspconfig.elixirls.setup`, it only needs a `cmd`
path, the rest can be used as default. Same about `capabilities` thingy – auto-
completion plugins work fine without it (as well as diagnostic messages).

Though I want to leave the notes about the settings options I found for ElixirLS
here, as well as it might be useful in future.

> I noticed that at least `dialyzerEnabled = false` affects if we get warnings
> or errors about unused variabls or wrong specs in the Vim. By default, this
> option is set to `true` (which is fine by me).

```lua
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- See more information about Elixir LS itself (capabilities, settings, etc.) here:
-- https://github.com/elixir-lsp/elixir-ls/blob/master/apps/language_server/lib/language_server/server.ex
lspconfig.elixirls.setup({
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
})
```

Another finding is related `lspkind` plugin that preformats the text. When we
use its `menu` option it effectively rewrites anything that might be in the
original LSP response field, so if we want to use this information we have two
options: either not using `meny` at all, or use `before` and write our own
handler, like this:

```lua
-- cmp.setup({...
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      maxwidth = 50,
      ellipsis_char = '…',
      -- check https://github.com/onsails/lspkind.nvim/blob/master/lua/lspkind/init.lua
      -- for details about before function where we can transform the item
      before = function(entry, item)
        local labels = {
          nvim_lsp = '[LSP]',
          nvim_lsp_signature_help = '[LSP]',
          vsnip = '[VSnip]',
          buffer = '[Buffer]',
          path = '[Path]'
        }
        local details = item.menu
        local truncated = vim.fn.strcharpart(details, 0, 50)

        if truncated ~= details then
          item.menu = labels[entry.source.name] .. ' ' .. truncated .. '…'
        else
          item.menu = labels[entry.source.name] .. ' ' .. details
        end

        --print(vim.inspect(item)) -- see debug output in :messages

        return item
      end
    },
  })
})
```
