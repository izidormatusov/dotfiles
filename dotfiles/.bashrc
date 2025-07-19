# Basic setup {{{
# If not running interactively, don't do anything
# Remotely executed commands tend to source .bashrc, see
# https://unix.stackexchange.com/a/257613/7612
[[ $- != *i* ]] && return
# }}}

# Shell prompt {{{
export PS1="\
\[\e[0m\]\t \
\$(__ret_code=\$?; if [[ \$__ret_code -gt 0 ]]; then \
  printf \"\[\033[01;31m\][E: \$__ret_code]\[\033[0m\] \"; \
fi)\
\[\e[01;34m\]\W\[\e[0m\] \$ "
# }}}

# Bash options {{{
# See https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# Automatically correct minor mistakes in cd path
shopt -s cdspell
# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
# Do not do autocomplete on empty command
shopt -s no_empty_cmd_completion
# Allow comments in the commands
shopt -s interactive_comments
# }}}

# Bash history {{{
# Attempts to save all lines of a multiple-line command in the same history
# entry. This allows easy re-editing of multi-line commands.
shopt -s cmdhist
# Append history rather than overriding it.
shopt -s histappend
# As much size as possible
HISTFILESIZE=64000
HISTSIZE=64000
# Show date when the history was executed
HISTTIMEFORMAT='[%F %T %z] '
# Store evey command (do not ignore leading space and store duplicate commands)
HISTCONTROL=
# }}}

# Shell options {{{
# Disable MacOS deprecation warning
export BASH_SILENCE_DEPRECATION_WARNING=1

# By default make my files visible only to the current user
# You can see the symbolic representation by umask -S
umask 0077

# Allow less to process binary files like pdf, zip, etc. See lesspipe(1)
command -v lesspipe > /dev/null && eval $(lesspipe)

# Linux requires dircolors macros to set colors for the output
command -v dircolors > /dev/null && eval $(dircolors --bourne-shell)
# }}}

# Exports {{{
export EDITOR=vim

export HOMEBREW_REPOSITORY="/opt/homebrew"
if [ -d "$HOMEBREW_REPOSITORY" ]; then
  export HOMEBREW_PREFIX="$HOMEBREW_REPOSITORY"
  export HOMEBREW_CELLAR="$HOMEBREW_REPOSITORY/Cellar"
  export PATH="$HOMEBREW_REPOSITORY/bin:$HOMEBREW_REPOSITORY/sbin${PATH+:$PATH}"
  export MANPATH="$HOMEBREW_REPOSITORY/share/man${MANPATH+:$MANPATH}:"
  export INFOPATH="$HOMEBREW_REPOSITORY/share/info:${INFOPATH:-}"

  [[ -r /opt/homebrew/etc/bash_completion ]] && source /opt/homebrew/etc/bash_completion
else
  unset HOMEBREW_REPOSITORY
fi

export GOPATH="$HOME/.go"
export PATH="$HOME/.bin:$PATH:$GOPATH/bin:$HOME/.cargo/bin:$HOME/.local/bin"
export PASSWORD_STORE_DIR="$HOME/code/pass"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
[ -f $RIPGREP_CONFIG_PATH ] || unset RIPGREP_CONFIG_PATH
# }}}

# Bash macros {{{

# Move to directory of the given python module, e.g. pycd flask
pycd() { # {{{
  pushd $(python3 -c "import os.path, $1; print(os.path.dirname($1.__file__))")
} # }}}

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alert() { # {{{
  local status=$([ $? = 0 ] && echo S || echo E)
  local text="$@"
  if [ -z "$text" ]; then
    local command=$(HISTTIMEFORMAT='' builtin history 2 |
      sed -e '
          s/^[ \t]*[0-9][0-9]*[ \t]*//
          s/[;&|][ \t]*alert[ \t]*$//
          s/[ \t][ \t]*/ /g
          s/[ \t]*$//
          ' |
      tail -n 1)
    text="\`${command}\`"
  fi
  command alert "$status" "$text"
} # }}}

# }}}

# Tool setup {{{
command -v zoxide > /dev/null && {
  # z - jumps to a directory
  # zi - shows the search for the jump
  export _ZO_ECHO=1
  eval "$(zoxide init bash)"
}

command -v direnv > /dev/null && eval "$(direnv hook bash)"

if [ -e /opt/homebrew/opt/fzf/shell/key-bindings.bash ]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.bash
elif [ -d /usr/share/doc/fzf/ ]; then
  source /usr/share/doc/fzf/examples/key-bindings.bash
fi

# }}}

# Source related files
[ -r ~/.aliases ] && source ~/.aliases
[ -r ~/.work.aliases ] && source ~/.work.aliases
[ -r ~/.work.bashrc ] && source ~/.work.bashrc

# Reset status variable so that it does not report error
# if the last source fails
true
