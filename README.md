# cr0t's dotfiles

A set of configuration files I prefer to have across my computers.

> [!tip]
>
> On macOS consider to set keyboard repeat to the fastest values via console:
>
> ```console
> defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
> defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)
> ```
>
> [Source](https://apple.stackexchange.com/questions/10467/how-to-increase-keyboard-key-repeat-rate-on-os-x)

## Installation

These files use "symlink" strategy, and it worked for many years on both macOS
and Linux. `setup.sh` manages creation of the symlinks to various directories
or directly to some files in the user home, so it is safe in most cases.

Clone the repo, link:

```console
git clone https://github.com/cr0t/dotfiles.git ~/.dotfiles
~/.dotfiles/setup.sh link
```

Enjoy!

> To clean up the links, run `~/.dotfiles/setup.sh clean`.

### Brew in Apps and Utilities

In case of fresh machine installation, consider to run `brew bundle --no-lock`
command in the ~/.dotfiles directory to install command line apps, utilities,
and desktop applications.

See [`Brewfile`](Brewfile) for the apps.

## Neovim/Vim

Check [Neovim as asdf's plugin](#extra-neovim-as-asdfs-plugin) notes on how to
install up-to-date version of Neovim in Ubuntu, for example.

Follow this checklist:

- Nerd Fonts (MesloLGS)
- `vim -c PlugInstall -c PlugUpgrade -c PlugUpdate -c qall`
- `:TSInstall`
- `:LspInstall`

> [!note]
>
> Please, refer to the [docs/NVIM.md](docs/NVIM.md) for details.

## Configure `asdf`

Install all the plugins we will need:

```console
asdf plugin add erlang
asdf plugin add elixir
asdf plugin add nodejs
asdf plugin add ruby
```

…and the languages themselves:

```console
env KERL_BUILD_DOCS=yes KERL_CONFIGURE_OPTIONS="--without-javac" asdf install erlang 26.2.2
asdf install elixir 1.16.1-otp-26
asdf install nodejs 20.11.1
asdf install ruby 3.2.2
```

> [!note]
>
> These options for Erlang installation command will ensure building the docs,
> so we can use `h :rand.uniform` (and similar) commands during IEx sessions.

Now we can set globally available (for the user, of course) languages versions:

```console
asdf global erlang 26.2.2
asdf global elixir 1.16.1-otp-26
asdf global nodejs 20.11.1
asdf global ruby 3.2.2
```

> `asdf global ...` command adds settings to `~/.tool-versions` file; we can
> create and update this file manually.

### Extra: Neovim as `asdf`'s plugin

Consider installing Neovim via `asdf` plugin.

In Ubuntu, for example, it allows installing stable version 0.8+ (apt's version
is only ~0.7 at the moment of writing).

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
Host * !gitlab.company.org
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

# specify a key for a specific host, see `Host * ...` section too
Host gitlab.company.org
  Hostname gitlab.company.org
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
> By default, we set up `$PATH` to check `~/.local/bin` directory too. If you
> need to have some scripts available only on some particular machine (like
> temp scripts for your current projects) which you do not want to commit to
> this repo, put these scripts there.

### Adding `elgato.sh` to Crontab

Consider adding this little automatization helper to run after each boot by
adding this to crontab:

```text
@reboot /Users/cr0t/.dotfiles/littles/elgato.sh &
```

## Set Local Environment Variables

`fish`'s alternative to `.bashrc` is located at `~/.config/fish/config.fish`.
We do not overwrite this file by these dotfiles, so it's totally local to a
machine.

To define a new variable we do something like that in this file:

```fish
if status is-interactive
    set -x GITLAB_TOKEN 'glpat-***'
    set -x KUBECONFIG "$HOME/.kube/config-company:$HOME/.kube/config-homelab"
    set -x HOMEBREW_NO_ENV_HINTS 1
    set -x EDITOR nvim
end
```

## Extra

Check [`docs/EXTRA.md`](docs/EXTRA.md) for more notes about these dotfiles, or
[`docs/KUBERNETES.md`](docs/KUBERNETES.md) for my personal k8s cheat sheet.
