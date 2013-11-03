# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\[\033[0;35m\]$?\[\033[0m\]] `date +%H:%M` \[\033[01;34m\]\W\[\033[0m\] > '
PS2='>> '

# notify of bg job completion immediately
set -o notify

# shell opts. see bash(1) for details
shopt -s cdspell >/dev/null 2>&1
shopt -s histappend >/dev/null 2>&1
shopt -s interactive_comments >/dev/null 2>&1
shopt -u mailwarn >/dev/null 2>&1
shopt -s no_empty_cmd_completion >/dev/null 2>&1

# default umask
umask 0022

export EDITOR=/usr/bin/vim

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Local completions
if [ -f $HOME/.bash_completion ]; then
    . $HOME/.bash_completion
fi

alias '..'='cd ..'
alias '...'='cd ../..'
alias 'll'='ls -hlF --color=auto'
alias 'ls'='ls -F --color=auto'
alias 'grep'='grep --color=auto'
alias 'egrep'='egrep --color=auto'
alias 'diff'='colordiff'
alias 'open'='xdg-open'
# No more Octave SPAM
alias 'octave'='octave --silent'
alias 'vim'='vim -p'
# Quicker reset of screen
alias 'clear'='echo -en "\033c"'

alias 'clpy'='find -type f -name \*.pyc -exec rm {} \;'

which hub && alias 'git'='hub'
alias g='git status -sb'
alias ga='git add'
alias gd='git diff'
alias gci='git commit'
alias grm='git rm'
alias gmv='git mv'

function fn() {
    find -name "*$**"
}

alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'

eval `dircolors -b`
export PATH="$HOME/.bin:$PATH"

export PYTHONSTARTUP=$HOME/.pythonrc

# Virtualenv wrapper
_VIRTUALENVWRAPPER="/usr/local/bin/virtualenvwrapper.sh"
if [ -e "$_VIRTUALENVWRAPPER" ] ; then
    source $_VIRTUALENVWRAPPER

    alias 'w'='workon'
    complete -o default -o nospace -F _virtualenvs w
fi

# Tangent stuff
export TANGENT_USER="matusovi"
