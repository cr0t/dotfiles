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
