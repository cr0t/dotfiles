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

Check [Neovim as asdf's plugin](#extra-neovim-as-asdfs-plugin) notes on how to
install up-to-date version of Neovim in Ubuntu, for example.

### Nerd Fonts

In order to leverage full power of file type icons in Vim/Neovim, we need to
install [specially patched fonts (Nerd Fonts)](https://github.com/ryanoasis/nerd-fonts)
into the system. Below are quick instructions for macOS.

1. Go to https://github.com/ryanoasis/nerd-fonts/releases page, find latest one.
2. At the bottom of the page (in the 'Assets' section) find and download archives
   with the fonts you're interested. In my case, I use Meslo and rarely JetBrains Mono.
3. Unpack and install the fonts you need (I prefer MesloLGS from the all Meslo
   variety of the fonts).

### How to Use [vim-plug](https://github.com/junegunn/vim-plug)

Please, remember to run `:PlugInstall` command when you open your vim–to ensure
that all plugins are installed and up to date.

Alternatively, you can run this command from the shell directly:

```console
vim -c PlugInstall -c PlugUpgrade -c PlugUpdate -c qall
```

> To update plugins, you can run `vim -c PlugUpgrade -c PlugUpdate -c qall` from
> time to time.

### `nvim-treesitter` Notes

The goal of nvim-treesitter is both to provide a simple and easy way to use the
interface for tree-sitter in Neovim and to provide some basic functionality such
as highlighting based on it.

The installation of the languages and configuration is mostly automated, but it
is important to watch it carefully, as it's not stable yet. Read more information
[here](https://github.com/nvim-treesitter/nvim-treesitter).

Check [`dot.config/nvim/treesitter.lua`](dot.config/nvim/treesitter.lua) for details.

### `nvim-lsp` Notes

After we have installed Vim's plugins, we need to do some more manual actions
(I'm too lazy to automate this) to install Language Server Protocols servers of
the languages we want to have write comfortably in.

For example, for Elixir we need to download and unpack latest ElixirLS binaries.
Follow these instructions:

1. Find latest release here https://github.com/elixir-lsp/elixir-ls/releases.
2. Download zip-file with the Elixir version you want to use (Elixir 1.14 and
   OTP 25.1, for example).
3. Create directory and unarchive into it:

   ```console
   mkdir -p ~/.local/lsp/elixir-ls
   unzip elixir-ls-1.14-25.1.zip -d ~/.local/lsp/elixir-ls
   ```

> NOTE: Check the actual path in the `~/.config/nvim/nvim-lspconfig.lua` file.

## Configure `asdf`

Install all the plugins we will need:

```console
asdf plugin add erlang
asdf plugin add elixir
asdf plugin add nodejs
asdf plugin add ruby
asdf plugin add haskell
```

...and the languages themselves:

```console
env KERL_BUILD_DOCS=yes KERL_CONFIGURE_OPTIONS="--without-javac" asdf install erlang 26.1.2
asdf install elixir 1.15.2-otp-26
asdf install nodejs 20.9.0
asdf install ruby 3.2.2
asdf install haskell 9.6.2
```

> **Note on `env` for Erlang:** these options will build the docs so they will be come available in
> the IEx sessions.

Now we can set globally available (for the user, of course) languages versions:

```console
asdf global erlang 26.1.2
asdf global elixir 1.15.2-otp-26
asdf global nodejs 20.9.0
asdf global ruby 3.2.2
asdf global haskell 9.6.2
```

> `asdf global ...` command adds settings to `~/.tool-versions` file; we can create
> and update this file manually if we want.

### Extra: Neovim as `asdf`'s plugin

Consider to install Neovim via `asdf` plugin.

In Ubuntu, for example, it will allow to install stable version 0.8+ (apt
version is up to 0.7 at the moment of writing).

```console
asdf plugin add neovim
asdf install neovim 0.9.4
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

```text
Host *
  UseKeychain yes
  # ForwardAgent Yes # WARNING: this will forward keys to all the hosts you connect!
  AddKeysToAgent Yes
  IdentityFile ~/.ssh/id_ed25519
  PreferredAuthentications publickey

Host example.com
  User admin
  ServerAliveInterval 300
  ServerAliveCountMax 2

Host under-tv
  Hostname 192.168.0.2
  User media

Host gitlab.company
  Hostname gitlab.example.com
  IdentityFile ~/.ssh/id_ed25519_company
```

> [!note]
>
> To generate SSH keys for we can use `ssh-keygen` like this:
>
> `ssh-keygen -t ed25519 -C "sergey.kuznetsov@example.com" -f ~/.ssh/id_ed25519_company_name`

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

### Adding `elgato.sh` to Crontab

Consider to add this little automatization helper to run after each boot by
adding this to crontab:

```text
@reboot /Users/cr0t/.dotfiles/littles/elgato.sh &
```

## Set Local Environment Variables

`fish`'s alternative to `.bashrc` is located at `~/.config/fish/config.fish`.
We do not overwrite this file by this dotfiles, so it's totally local to machine.

To define a new variable we do something like that in this file:

```fish
if status is-interactive
    set -x GITLAB_TOKEN 'glpat-***'
    set -x KUBECONFIG "$HOME/.kube/config-company:$HOME/.kube/config-homelab"
end
```

## Extra

Check [`docs/EXTRA.md`](docs/EXTRA.md) for more notes about these dotfiles.
