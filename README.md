# cr0t dotfiles

A set of configuration files I prefer to have across machines I use.

## Installation

Clone it, link them:

```console
git clone https://github.com/cr0t/dotfiles.git ~/.dotfiles
~/.dotfiles/setup.sh link
```

Enjoy!

> To clean up the links, run `~/.dotfiles/setup.sh clean`.

### Brew in Apps and Utilities

In case of fresh machine installation, consider to run `brew bundle --no-lock`
command in the ~/.dotfiles directory to install utilities and command line apps.

See [`Brewfile`](Brewfile) for the list of apps to install.

## Neovim/Vim

### Nerd Fonts

In order to leverage full power of file type icons in Vim/Neovim, we need to install [specially patched fonts (Nerd Fonts)](https://github.com/ryanoasis/nerd-fonts) into the system. Below are quick instructions for macOS.

1. Go to https://github.com/ryanoasis/nerd-fonts/releases page, find latest one.
2. At the bottom of the page (in the 'Assets' section) find and download archives with the fonts you're interested. In my case, I use Meslo and rarely JetBrains Mono.
3. Unpack and install the fonts you need (I prefer MesloLGS from the all Meslo variety of the fonts).

### How to Use [vim-plug](https://github.com/junegunn/vim-plug)

Please, remember to run `:PlugInstall` command when you open your vim–to ensure
that all plugins are installed and up to date.

Alternatively, you can run this command from the shell directly:

```console
vim -c PlugInstall -c PlugUpgrade -c PlugUpdate -c qall
```

> To update plugins, you can run `vim -c PlugUpgrade -c PlugUpdate -c qall` from time to time.

### `nvim-treesitter` Notes

The goal of nvim-treesitter is both to provide a simple and easy way to use the
interface for tree-sitter in Neovim and to provide some basic functionality such
as highlighting based on it.

The installation of the languages and configuration is mostly automated, but it
is important to watch it carefully, as it's not stable yet. Read more information
[here](https://github.com/nvim-treesitter/nvim-treesitter).

Check [`dot.config/nvim/treesitter.lua`)[dot.config/nvim/treesitter.lua] for details.

### `coc.nvim` Notes

After we install vim plugins, we might need to install coc-engines we need.

For example, for Elixir we need to do next. Inside `vim` session we need to run
`:CocInstall coc-elixir` command. As well, as we might need to download and unpack
latest ElixirLS binaries.

Read more here: https://github.com/elixir-lsp/coc-elixir#vim-plug. Or follow
these instructions:

1. Find latest release here https://github.com/elixir-lsp/elixir-ls/releases
2. Download zip-file with the Elixir version you want to use (1.13, for example)
3. If you already ran `:CocInstall coc-elixir` command, then it created needed
   folder, and we can run something like this:

   ```console
   unzip elixir-ls-1.14-25.1.zip -d ~/.config/coc/extensions/node_modules/coc-elixir/els-release
   ```

## Configure `asdf`

Create `~/.tool-versions` file with the global languages versions we will use, for example:

```text
elixir 1.14.3-otp-25
erlang 25.2.3
haskell 9.0.2
nodejs 16.19.0
ruby 3.1.2
```

Then install all the plugins we need:

```console
asdf plugin add erlang
asdf plugin add elixir
asdf plugin add haskell
asdf plugin add nodejs
asdf plugin add ruby
```

...and the languages themselves:

```console
env KERL_BUILD_DOCS=yes asdf install erlang 25.2.3 # Erlang docs will be available in IEx
asdf install elixir 1.14.3-otp-25
asdf install haskell 9.0.2
asdf install nodejs 16.19.0
asdf install ruby 3.1.2
```

### Extra: Neovim as `asdf`'s plugin

Consider to install Neovim via `asdf` plugin.

In Ubuntu, for example, it will allow to install stable version 0.8+ (apt
version is up to 0.7 at the moment of writing).

```console
asdf plugin add neovim
asdf install neovim 0.8.3
asdf global neovim stable
```

## Setup `.ssh`

Don't forget to create the `~/.ssh` folder and set proper permissions:

```console
chmod 700 ~/.ssh
chmod -R go= ~/.ssh
chmod -w ~/.ssh/id_rsa*
chmod -w ~/.ssh/id_ed*
```

Here is an example of `~/.ssh/config` file:

```console
Host *
  ForwardAgent Yes # Be careful! It will forward to all the hosts, you maybe want to avoid this
  AddKeysToAgent Yes
  IdentityFile ~/.ssh/id_rsa

Host example.com
  User admin
  ServerAliveInterval 300
  ServerAliveCountMax 2

Host under-tv
  Hostname 192.168.0.2
  User media
```

## Directory `littles`

Contains a set of my tiny scripts, a variety of helpers, snippets, etc. Most of
them are pretty much for my personal needs. Read the source and, if you need,
install them manually to the bin directory; or make them available in your
`PATH` env variable, like this:

```bash
export PATH="$PATH:~/.dotfiles/littles"
```

> **Local `littles`**
>
> By default we set up `$PATH` to look into `~/.local/bin` directory too. If
> you need to have some scripts available only on some particular machine (like
> temp scripts for your current projects) which you do not want to commit to
> this repo, put these scripts there.

## Extra

### Vale Spellchecker

Download and install `vale`'s configured styles with `vale sync` command. Run it from home directory after linking all the configuration files.

### Copy and Update `.gitconfig.local`

After setting up these files, you'll see `.gitconfig.local.example` one that is
created in the home directory. You need to check what it contains and update if
needed.

```console
cp ~/.gitconfig.local.example ~/.gitconfig.local
```

### How to Use [tmux plugins](https://github.com/tmux-plugins)

Please install `tpm` before you can use tmux plugins:

```console
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
