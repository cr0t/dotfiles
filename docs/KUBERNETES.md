# Kubernetes Notes

## Working with Multiple Clusters

Firstly, we need to ensure that we have saved all the clusters config files we
need in the `~/.kube` directory. We can use arbitrary names, or follow some
sort of convention, e.g.: `config-homelab`, `config-company`, etc.

Then, we must export `KUBECONFIG`. For fish we can do it in
`~/.config/fish/config/fish`:

```fish
if status is-interactive
    set -x KUBECONFIG "$HOME/.kube/config-company:$HOME/.kube/config-homelab"
end
```

> [!info]
>
> This will merge all the fields from all the listed config files into a bigger
> config. We can check it by `kubectl config view` command.

Having that configured, we can start switching between _contexts_ manually, but
it's better to install and use [`kubectx`](https://github.com/ahmetb/kubectx)
utility. _It's already in the `Brewfile`._ It allows to quickly switch between
clusters and namespaces, or provide nicer aliases. An example:

```console
# aliases
kubectx homelab=kubernetes-admin@kubernetes
kubectx company=arn:aws:eks:eu-central-1:3...staging-eu

# switching between contexts
kubectx homelab
kubectx -
```
