# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\[\033[0;35m\]$?\[\033[0m\]] `date +%H:%M` \[\033[01;34m\]\W\[\033[0m\] > '
PS2='>> '

# notify of bg job completion immediately
set -o notify

# use vi for editing mode (after pressing ESC or CTRL+[
# Note that "fc" can be use to "fix command" in $EDITOR
#set -o vi

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
# Run tmux with 256 colors
alias 'tmux'='tmux -2'
# No more Octave SPAM
alias 'octave'='octave --silent'
# Quicker reset of screen
alias 'clear'='echo -en "\033c"'

alias 'clpy'='find -type f -name \*.pyc -exec rm {} \;'

alias 'zuri'='mplayer http://statslive.infomaniak.ch/playlist/energyzuerich/energyzuerich-high.mp3/playlist.pls'

eval "$(hub alias -s)"
alias g='git status -sb'
alias ga='git add'
alias gd='git diff'
alias gdc='git diff --cached'
alias gci='git commit -v'
alias gco='git checkout'
alias grm='git rm'
alias gmv='git mv'

function fn() {
    find -name "*$**"
}

alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'
# Source highlighting
alias scat='pygmentize -f console256 -O "style=monokai"'

alias pql='sudo -u postgres psql'

genpasswd() {
    # Generate random password
    local l=$1
    [ "$l" == "" ] && l=20
    tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}

clone() {
    # Clone tangentlabs repo
    local org="tangentlabs"
    local repo=""

    if [ $# -ge 2 ] ; then
        local org="$1"
        local repo="$2"
        shift 2
    elif [ $# -eq 1 ] ; then
        local repo="$1"
        shift 1
    else
        echo "Usage: clone [org] repo"
    fi
    git clone "git@github.com:$org/$repo.git" $@
}

eval `dircolors -b`
export PATH="$HOME/.bin:$PATH:/opt/android/platform-tools:/opt/android/tools:/usr/local/go/bin"
export GOPATH="$HOME/go"

export PYTHONSTARTUP=$HOME/.pythonrc

# Virtualenv wrapper
_VIRTUALENVWRAPPER="/usr/local/bin/virtualenvwrapper.sh"
if [ -e "$_VIRTUALENVWRAPPER" ] ; then
    source $_VIRTUALENVWRAPPER

    # Use system-site packages (PyZen, flake8, etc)
    alias 'mkvirtualenv'='mkvirtualenv --system-site-packages'
    alias 'w'='workon'
    complete -o default -o nospace -F _virtualenvs w
fi

# Tangent stuff
export TANGENT_USER="matusovi"

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# added by travis gem
[ -f /home/imatusov/.travis/travis.sh ] && source /home/imatusov/.travis/travis.sh
