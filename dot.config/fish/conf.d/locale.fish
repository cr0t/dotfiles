# we need LC_* variables for SSH-ing into other machines (Debian-based, in particular)
set -gx LC_CTYPE C.UTF-8
set -gx LC_ALL C.UTF-8
set -gx LANG en_US.UTF-8
