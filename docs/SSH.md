# SSH Notes

Here is an example of `~/.ssh/config` file:

> [!NOTE]
>
> In the example below, we take into account that our SSH-keys are generated with passphrases and
> we use ssh-agent (plus macOS' Keychain mechanism) to avoid typing passphrase every time we ssh
> somewhere.
>
> There a big caveat with the ssh-agent and multiple keys: it's impossible (at least, we did not
> find a solution yet) to specify a particular key for a particular host (or subdomain); `ssh` just
> do not respect `IdentityFile <path/to/key>` option (even with `IdentitiesOnly yes`) when we use
> ssh-agent.

```text
Host * !gitlab.company.org
  UseKeychain yes
  # ForwardAgent Yes # WARNING: this will forward keys to all the hosts you connect!
  AddKeysToAgent Yes
  IdentityFile ~/.ssh/id_ed25519
  PreferredAuthentications publickey

Host example.com
  User admin
  ForwardAgent Yes
  ServerAliveInterval 300
  ServerAliveCountMax 2

Host under-tv
  Hostname 192.168.0.2
  User media

# specify a key for a specific host, see `Host * ...` section too
Host gitlab.company.org
  Hostname gitlab.company.org
  IdentityFile ~/.ssh/id_ed25519_company

  Include /Users/cr0t/.colima/ssh_config
```

> [!NOTE]
>
> To generate SSH keys for we can use `ssh-keygen` like this:
>
> `ssh-keygen -t ed25519 -C "sergey.kuznetsov@example.com" -f ~/.ssh/id_ed25519_company_name`

### Note on GitHub Organizations

If we want to use specific SSH-keys for a particular organization on GitHub, we must make similar
changes to the `~/.ssh/config` and to `.gitconfig` too! Step-by-step we need to do the following.

Set a "virtual" GitHub host in the `~/.ssh/config`:

```text
Host * !company.github.com
  UseKeychain yes
  AddKeysToAgent Yes
  IdentityFile ~/.ssh/id_ed25519
  PreferredAuthentications publickey

Host example.com
  User admin

Host company.github.com
  Hostname github.com
  IdentityFile ~/.ssh/id_ed25519_company
```

Load specific company's `.gitconfig` from the main one (`~/.gitconfig`):

```text
; ...
[includeIf "gitdir:~/Workspace/company/**"]
  path = ~/Workspace/company/.gitconfig
```

In the actual company's `.gitconfig` we can set various options, but importantly to set the `url`:

```text
[user]
  name = Sergey Kuznetsov
  email = sergey.kuznetsov@company.com
  signingkey = ssh-ed25519 AAAAC3Nz...zfAq1RW sergey.kuznetsov@company.com
[url "git@company.github.com:company-com"]
  insteadOf = git@github.com:company-com
  insteadOf = https://github.com/company-com
```

This will make `git` automatically convert any organization's repositories URLs to our virtual
GitHub's domain for SSH access. In addition, we can also use specific email address and configure
a specific key for commits signature.
