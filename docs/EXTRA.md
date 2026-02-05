# Extra Notes

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

## Login Banner Hint

To turn off MOTD (or login banner), we can do `touch ~/.hushlogin`.
