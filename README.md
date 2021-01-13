# cr0t dotfiles

A set of configuration files I prefer to have across machines I use.

## Installation

Clone it, link them:

```bash
$ git clone https://github.com/cr0t/dotfiles.git ~/.dotfiles
$ ~/.dotfiles/setup.sh link
```

Enjoy!

> To clean up the links, run `~/.dotfiles/setup.sh clean`.

## Setup `.ssh`

Don't forget to set up the `~/.ssh` folder. Here is an example of `~/.ssh/config` file:

```
Host example.com
  User hoster
  ForwardAgent yes
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
$ export PATH="$PATH:~/.dotfiles/littles"
```

## How to use [vim-plug](https://github.com/junegunn/vim-plug)

Please, remember to run `:PlugInstall` command when you open your vim–to ensure
that all plugins are installed and up to date.

Alternatively, you can run this command from the shell directly:

```bash
$ vim -c PlugInstall -c qall
```

## How to use [tmux plugins](https://github.com/tmux-plugins)

Please install `tpm` before you can use tmux plugins:

```bash
$ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## Copy and update `.gitconfig.local`

After setting up these files, you'll see `.gitconfig.local.example` one that is
created in the home directory. You need to check what it contains and update if
needed.

```bash
$ cp ~/.gitconfig.local.example ~/.gitconfig.local
```
