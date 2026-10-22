# cr0t's dotfiles

A set of configuration files I prefer to have across my computers.

## Installation

Files are symlinked into place by `setup.sh`, which has worked for years on both
macOS and Linux:

```console
git clone https://github.com/cr0t/dotfiles.git ~/.dotfiles
~/.dotfiles/setup.sh link
```

To clean up the links, run `~/.dotfiles/setup.sh clean`.

### macOS tweaks

Speed up the keyboard repeat (see [macos-defaults.com](https://macos-defaults.com/)
for more options):

```console
defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1         # normal minimum is 2 (30 ms)
```

Optionally, make fonts in Alacritty less bold:

```console
defaults write org.alacritty AppleFontSmoothing -int 0
```

(When installed) Karabiner-Elements is configured to use CapsLock as CTRL on all
keyboards.

### Brew apps

On a fresh macOS machine, run `brew bundle --no-lock` in `~/.dotfiles` to
install the apps and utilities from the [`Brewfile`](Brewfile).

> [!tip]
>
> Some apps (e.g., `chromedriver`) lack signatures modern macOS requires, and
> the right click → "Open" trick no longer works. Remove the quarantine flag:
>
> ```shell
> xattr -d com.apple.quarantine $(which chromedriver)
> ```

### Docker CLI and Colima

We use the free Docker CLI with [Colima](https://github.com/abiosoft/colima) as
the runtime instead of Docker Desktop (all packages are in the `Brewfile`).
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

Run `colima start` and wait for the VM before using Docker commands. To push to
GitHub Container Registry, log in with a token that has the `write:packages`
scope ([generate one here](https://github.com/settings/tokens)):

```console
docker login --username cr0t ghcr.io
```

Based on this [blog post](https://dev.to/elliotalexander/how-to-use-docker-without-docker-desktop-on-macos-217m).

## Languages and tools: `mise`

We use [mise](https://mise.jdx.dev/) for language runtimes and tools. The global
[`config.toml`](config.toml) (Erlang, Elixir, Node.js, Ruby, Zig) is symlinked to
`~/.config/mise/config.toml` by `setup.sh link`.

Install everything defined in the config:

```console
env KERL_BUILD_DOCS=yes KERL_CONFIGURE_OPTIONS="--without-javac" mise install
```

> [!note]
>
> `KERL_BUILD_DOCS=yes` builds the Erlang docs, so `h :rand.uniform` (and
> similar) works in IEx.

To bump a version, run `mise use --global <tool>@<version>` and commit the
updated `config.toml`.

## Neovim/Vim

Checklist:

- Nerd Fonts (MesloLGS)
- Languages installed via `mise` (Elixir, Erlang, Node.js, Ruby), so Mason can
  set up all the LSPs

On Ubuntu, apt's Neovim is old (~0.7), so install a recent one with `mise`:

```console
mise use --global neovim@stable
```

See [docs/NVIM.md](docs/NVIM.md) for details.

## Setup `.ssh`

Create `~/.ssh` and set proper permissions (see also [`docs/SSH.md`](docs/SSH.md)):

```console
chmod 700 ~/.ssh
chmod -R go= ~/.ssh
chmod -w ~/.ssh/id_rsa* ~/.ssh/id_ed*
```

## Directory `littles`

My tiny scripts and helpers, mostly for personal needs. Read the source and
install what you need into a bin directory, or add the directory to `PATH`:

```bash
export PATH="$PATH:$HOME/.dotfiles/littles"
```

`~/.local/bin` is on `$PATH` too: put machine-specific or temporary scripts
there, so they stay out of this repo.

## Local environment variables and shell setup

`~/.config/fish/config.fish` is not overwritten by these dotfiles, so it stays
local to the machine. Put machine-specific variables there:

```fish
if status is-interactive
    set -x GITLAB_TOKEN 'glpat-***'
    set -x KUBECONFIG "$HOME/.kube/config-company:$HOME/.kube/config-homelab"
    set -x HOMEBREW_NO_ENV_HINTS 1
    set -x EDITOR nvim
end
```

## Extra

See [`docs/EXTRA.md`](docs/EXTRA.md) for more notes, or
[`docs/KUBERNETES.md`](docs/KUBERNETES.md) for my k8s cheat sheet.
