set lo_sbin "/usr/local/sbin"
set littles "$HOME/.dotfiles/littles/"
set vs_code "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Check if path exist and add it to the $PATH
set __paths $lo_sbin $littles $vs_code

for __path in $__paths
  if test -d $__path
    set -gx PATH $__path $PATH
  end
end
