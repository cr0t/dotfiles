# Neovim Notes

## Nerd Fonts

> [!important]
>
> For macOS, we install Meslo LG Nerd font via Homebrew cask, find
> `font-meslo-lg-nerd-font` in the [Brewfile](../Brewfile).

In order to leverage full power of file type icons in Vim/Neovim, we need to
install [specially patched fonts (Nerd Fonts)](https://github.com/ryanoasis/nerd-fonts)
into the system. Below are quick instructions for macOS.

1. Go to https://github.com/ryanoasis/nerd-fonts/releases page, find the latest
   one.
2. At the bottom of the page (in the 'Assets' section) find and download
   archives with the fonts you're interested. In my case, I use Meslo and
   rarely JetBrains Mono.
3. Unpack and install the fonts you need (I prefer MesloLGS from the all Meslo
   variety of the fonts).

## How to Use [vim-plug](https://github.com/junegunn/vim-plug)

Please, remember to run `:PlugInstall` command when you open your vim–to ensure
that all plugins are installed and up to date.

Alternatively, you can run this command from the shell directly:

```console
vim -c PlugInstall -c PlugUpgrade -c PlugUpdate -c qall
```

> To update plugins, you can run `vim -c PlugUpgrade -c PlugUpdate -c qall` from
> time to time.

## `nvim-treesitter` Notes

The goal of the `nvim-treesitter` is both to provide a simple and easy way to
use the interface for tree-sitter in Neovim and to provide some basic
functionality such as highlighting based on it.

The installation of the languages and configuration is mostly automated, but it
is important to watch it carefully, as it's not stable yet. Read more
information [here](https://github.com/nvim-treesitter/nvim-treesitter).

## `nvim-lsp` Notes

> [!warn]
>
> This section is outdated since we started to use `mason.nvim` plugin that
> manages language servers installations and updates. Leaving it here just for
> historical reasons.

After we have installed Vim's plugins, we need to do some more manual actions
(I'm too lazy to automate this) to install Language Server Protocols servers of
the languages we want to have written comfortably in.

For example, for Elixir we need to download and unpack latest ElixirLS binaries.
Follow these instructions:

1. Find the latest release here https://github.com/elixir-lsp/elixir-ls/releases.
2. Download zip-file with the Elixir version you want to use (Elixir 1.14 and
   OTP 25.1, for example).
3. Create directory and unzip into it:

   ```console
   mkdir -p ~/.local/lsp/elixir-ls
   unzip elixir-ls-1.14-25.1.zip -d ~/.local/lsp/elixir-ls
   ```

> NOTE: Check the actual path in the `~/.config/nvim/nvim-lspconfig.lua` file.

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
