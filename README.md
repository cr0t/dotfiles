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

See [https://macos-defaults.com/](https://macos-defaults.com/) for more options
that we can control using the `default` command.

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

### Brew Apps, Utilities, and Co.

In case of fresh machine installation, consider to run `brew bundle --no-lock`
command in the ~/.dotfiles directory to install command line apps, utilities,
and desktop applications.

See [`Brewfile`](Brewfile) for the apps.

> [!tip]
>
> Some of the apps (e.g., `chromedriver`) don't have all the signatures as
> modern macOS versions require. Right click and "Open" trick on the executable
> doesn't work anymore. We have to explicitly (and manually) let the macOS know
> that it's safe to run these binaries, for example like this:
>
> ```shell
> xattr -d com.apple.quarantine $(which chromedriver)
> ```

After installation, (considering you're on the macOS) configure Karabiner elements to
use CapsLock as CTRL on all keyboards.

> [!note]
>
> ...note to self: consider to include `~/.config/karabiner` in the dotfiles.

### Docker CLI and Colima

As we do not really need to use Docker Desktop (especially, because its license
might cost money in some cases), we use free CLI version. However, it cannot
work out-of-box and needs some _love_, or actually, **runtime**, for which we
use [Colima](https://github.com/abiosoft/colima). All of the packages we need
are in the [`Brewfile`](Brewfile), but we need a manual touch to do the magic.

Save this as `~/.docker/config.json`:

```json
{
  "auths": {},
  "cliPluginsExtraDirs": [
    "/opt/homebrew/lib/docker/cli-plugins"
  ],
  "credsStore": "osxkeychain",
  "currentContext": "colima"
}
```

Before running Docker-commands, run `colima start` and wait for VM to set up.

> [!tip]
>
> Don't forget to sign in to GitHub Registry (to push images there) by running:
>
> `docker login --username cr0t ghcr.io`
>
> Use a token with 'write:packages' scope as a password. You can generate one
> [here](https://github.com/settings/tokens).

This setup is based on this [blog post](https://dev.to/elliotalexander/how-to-use-docker-without-docker-desktop-on-macos-217m).

## Neovim/Vim

Check [Neovim as asdf's plugin](#extra-neovim-as-asdfs-plugin) notes on how to
install up-to-date version of Neovim in Ubuntu, for example.

Follow this checklist:

- Nerd Fonts (MesloLGS)
- Install ASDF plugins and Elixir, Erlang, Node.js, and Ruby _(to allow setting
up all the LSPs defined in Mason)_

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
asdf plugin add zig
```

…and the languages themselves:

```console
env KERL_BUILD_DOCS=yes KERL_CONFIGURE_OPTIONS="--without-javac" asdf install erlang 27.3
asdf install elixir 1.18.3-otp-27
asdf install nodejs 22.14.0
asdf install ruby 3.4.2
asdf install zig 0.14.0
```

> [!note]
>
> These options for Erlang installation command will ensure building the docs,
> so we can use `h :rand.uniform` (and similar) commands during IEx sessions.

Now we can set globally available (for the user, of course) languages versions:

```console
echo "erlang 27.3" >> ~/.tool-versions
echo "elixir 1.18.3-otp-27" >> ~/.tool-versions
echo "nodejs 22.14.0" >> ~/.tool-versions
echo "ruby 3.4.2" >> ~/.tool-versions
echo "zig 0.14.0" >> ~/.tool-versions
```

### Extra: Neovim as `asdf`'s plugin

Consider installing Neovim via `asdf` plugin.

In Ubuntu, for example, it allows installing stable version 0.8+ (apt's version
is only ~0.7 at the moment of writing).

```console
asdf plugin add neovim
asdf install neovim 0.10.0
asdf set --home neovim stable
```

## Setup `.ssh`

Don't forget to create the `~/.ssh` folder and set proper permissions:

```console
chmod 700 ~/.ssh
chmod -R go= ~/.ssh
chmod -w ~/.ssh/id_rsa*
chmod -w ~/.ssh/id_ed*
```

See examples and more information in the [`docs/SSH.md`](docs/SSH.md) file.

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
