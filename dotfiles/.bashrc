# Basic setup {{{
[ `uname -s` = "Darwin" ] && IS_MAC="true" || IS_MAC="false"
# }}}

# Shell prompt {{{
PS_SUFFIX='\[\e[01;34m\]\W\[\e[0m\]'
# Different prompt for mac to distinguish them
[ "$IS_MAC" = "true" ] && PS_SUFFIX='\[\e[0;36m\]\W \[\e[0;32m\]\[\e[0m\]'
export PS1="\
\[\e[0m\]\t \
\$(__ret_code=\$?; if [[ \$__ret_code -gt 0 ]]; then \
  printf \"\[\033[01;31m\][E: \$__ret_code]\[\033[0m\] \"; \
fi)\
$PS_SUFFIX \
\$ "
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
command -v lesspipe >/dev/null && eval `lesspipe`

# Linux requires dircolors macros to set colors for the output
command -v dircolors >/dev/null && eval `dircolors --bourne-shell`
# }}}

# Exports {{{
export EDITOR=/usr/bin/vim
export GOPATH="$HOME/code/go"
export PATH="$HOME/.bin:$PATH:$HOME/.cargo/bin"
export PASSWORD_STORE_DIR="$HOME/code/pass"
# }}}

# Homebrew {{{
if command -v brew >/dev/null
then

brew() { #{{{
  if ! [ \
    -O /usr/local/bin -a \
    -O /usr/local/etc -a \
    -O /usr/local/sbin -a \
    -O /usr/local/share -a \
    -O /usr/local/share/doc \
    ] ; then
    echo "Fixing permissions..."
    sudo chown -R $(whoami) \
      /usr/local/bin \
      /usr/local/etc \
      /usr/local/sbin \
      /usr/local/share \
      /usr/local/share/doc
    echo "Running brew..."
  fi
  command brew $*
} #}}}

# Install all dependencies from ~/.Brewfile
alias bbrew='$EDITOR ~/.Brewfile && brew bundle --global --verbose --no-upgrade'

# Use find from findutils
command -v gfind >/dev/null && alias find='gfind'

# Brew installation of pipenv makes pipenv believe it runs under virtualenv
export PIPENV_IGNORE_VIRTUALENVS=1

fi
# }}}

# Aliases {{{
alias ..='cd ..'
command -v colordiff >/dev/null && alias diff='colordiff'
alias egrep='egrep --color=auto'
alias grep='grep --color=auto'
alias less='less -R'
# Mac's ls does not have --color=auto, instead has -G
[ "$IS_MAC" = "true" ] && alias ls='ls -FG' || alias ls='ls -F --color=auto'
[ "$IS_MAC" = "true" ] && alias ll='ls -l@AeFGh' || alias ll='ls -hl'
alias py='ipython3'

# Require confirmation in case of overwriting an existing file
alias cp='cp -i'
alias mv='mv -i'

# Command line tool to find the biggest files
alias ncdu='ncdu --color dark'

# Simple CSV formatting
alias csv='column -s, -t'

alias title="printf '\033]2;%s\033\\'" # Set title in iTerm/tmux/terminal

# Remove color from the output https://stackoverflow.com/a/18000433
alias nocolor='sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"'

# Sane compatibility between Mac and Linux
command -v open >/dev/null || alias open='xdg-open'
command -v pbcopy >/dev/null || alias pbcopy='xsel --clipboard --input'
command -v pbpaste >/dev/null || alias pbpaste='xsel --clipboard --output'

# Extra information about the command like what is the size of memory and such
[ "$IS_MAC" = "true" ] && \
  alias timev='/usr/bin/time -l' || \
  alias timev='/usr/bin/time -v'

# httpserver 8000  # Serve the current folder
alias httpserver='python3 -m http.server'

# Tmux aliases
alias tmux='tmux -2'  # Run tmux with 256 colors
alias ta='tmux attach'  # add -CC for iTerm2 integration

tsw() {
  tmux swap-pane -t "${1-.1}"
  tmux switch-client -t "${1-.1}"
}

# Click on the window that will float above other windows, Linux only
command -v wmctrl >/dev/null || alias window_on_top='wmctrl -r :SELECT: -b add,above'

# MacOS preview
[ -f /usr/bin/qlmanage ] && alias preview='/usr/bin/qlmanage -p'

# Cleanup unused files: python cache, Mac metadata and empty folders
alias 'cleanup'="find . -depth \
  \( \( -type d -empty \) -or \
  \( -type f \( -name .DS_Store -or -name \*.pyc \) \) \
  \) -print -delete"

# Git aliases {{{
alias gs='git status -sb'
alias gd='git diff'
alias gdc='git diff --cached'
alias grc='git add -u && git rebase --continue'
#}}}

# }}}

# Bash macros {{{
genpasswd() { #{{{
  # Generate random password
  local l=$1
  [ "$l" == "" ] && l=20
  # MacOS requires overriding LC_ALL=C to prevent "tr: Illegal byte sequence"
  # error. See https://unix.stackexchange.com/a/45406
  LC_ALL=C tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)\\-+= < /dev/urandom | \
    head -c ${l} | xargs
} #}}}

colors() { #{{{
  # Helpfull tool thow show the different colors
  # Useful websites:
  # https://www.lihaoyi.com/post/BuildyourownCommandLinewithANSIescapecodes.html
  # https://misc.flogisoft.com/bash/tip_colors_and_formatting
  local i j

  if [ "$1" == "256" ]
  then
    printf "Forground color:  \e[1m\\\\e[38;5;{value}m\e[0m\n"
    printf "Background color: \e[1m\\\\e[38;5;{value}m\e[0m\n"
    echo

    # First 16 colors
    for i in {0..15}
    do
      printf "\e[38;5;${i}m%2d\e[48;5;${i}m  \e[0m" $i
    done
    echo
    echo

    # Colors
    for j in {16..231}
    do
        printf "\e[38;5;${j}m%3d\e[48;5;${j}m  \e[0m " $j
        [ $(( (j - 15) % 6 )) == 0 ] && echo
    done
    echo

    # Grayscale
    for start in 232 244
    do
      for (( j = start ; j < start +12 ; j++ )) do
            printf "\e[38;5;${j}m%3d\e[48;5;${j}m  \e[0m " $j
      done
      echo
    done

    return
  fi

  printf "Run \e[1;3m${FUNCNAME[0]} 256\e[0m for 256 colors version\n\n"
  printf "Color escapes are \e[1;3m%s\e[0m (echo uses \e[1;3m%s\e[0m or \e[1;3m%s\e[0m)\n" \
    '\e[${value};...;${value}m' '\033[...m' '\x1B[...m'
  printf "Values 30..37,  90..97  are \e[33mforeground colors\e[m\n"
  printf "Values 40..47, 100..107 are \e[43mbackground colors\e[m\n"
  printf "Values \e[1m1 = bold\e[m, \e[2m2 = dimmed\e[0m, "
  printf "\e[3m3 = cursive\e[0m, \e[4m4 = underline\e[0m\n"

  echo -e "\nRegular 16 colors"
  for i in {0..7}
  do
    for j in 0 60
    do
      local fgc=$((30 + i + j))
      local bgc=$((40 + i + j))

      printf "\e[${fgc}m\\\e[${fgc}m\e[0m  "
      printf "\e[${fgc};1m\\\e[${fgc};1m\e[0m  "
      printf "\e[${fgc};2m\\\e[${fgc};2m\e[0m  "
      printf "\e[${fgc};3m\\\e[${fgc};2m\e[0m  "
      printf "\e[${fgc};4m\\\e[${fgc};2m\e[0m  "
      printf "\e[${bgc}m\\\e[%3dm \e[0m\n" "${bgc}"
    done
  done

  echo
  # See http://rrbrandt.dee.ufcg.edu.br/en/docs/ansi/cursor and
  # https://en.wikipedia.org/wiki/ANSI_escape_code#Terminal_output_sequences
  echo "Cursor positions"
  echo -e " \033[1;3m\e[{line};{column}H\033[0m - moves cursor to the position (left corner is 0,0)"
  echo -e " \033[1;3m\e[2J\033[0m - clears the screen"
} #}}}

# Move to directory of the given python module, e.g. pycd flask
pycd () { # {{{
  pushd `python3 -c "import os.path, $1; print(os.path.dirname($1.__file__))"`
}
# }}}

w() { # {{{
  # Special cases
  case "$1" in
    # Example
    mynonstandardexample)
      cd ~/code/foo/bar
      source ~/.local/share/virtualenvs/foobar-*/bin/activate
      return
      ;;
  esac

  # Regular projects
  local project="$1"
  if [ -d ~/code/"$project" ]
  then
    cd ~/code/"$project"
    [ -f ~/.local/share/virtualenvs/"$project"-*/bin/activate ] && \
      source ~/.local/share/virtualenvs/"$project"-*/bin/activate
    return
  fi

  echo "Unknown project $project" >&2
  return 1
}

__w_completions()
{
  # You can list non-standard projects as a literal
  COMPREPLY=($(compgen -W "mynonstandardexample $(\ls ~/code/)" -- "${COMP_WORDS[1]}"))
}

complete -F __w_completions w
# }}}
# }}}
