# Neovim Notes

## Nerd Fonts

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

Check [`dot.config/nvim/treesitter.lua`](dot.config/nvim/treesitter.lua) for
details.

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
