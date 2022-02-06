# Set locale if it has not been set yet
[[ -z "$LC_ALL" ]] && export LC_ALL="en_US.UTF-8"

# Bash reads .bashrc only for interactive & non-login shells
# Mac launches Bash as login shell, reading the configuration
# from ~/.bash_profile
# https://stackoverflow.com/a/415444/99944
source ~/.bashrc
