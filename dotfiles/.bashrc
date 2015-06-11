# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -d "${HOME}/bin" ] ; then
  PATH=${HOME}/bin:${PATH}
  export PATH
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

JAVA_HOME=$(readlink -f /usr/bin/java)
JAVA_HOME=${JAVA_HOME%%/jre/*}
export JAVA_HOME

# Sort things sensibly
export LC_COLLATE=POSIX

#Oracle
export SQLPATH=${SQLPATH}${SQLPATH:+:}.:$HOME/.sqlplus
export TNS_ADMIN=/etc/oracle
for d in /usr/lib/oracle/*; do
  ORACLE_HOME=$d/client64
  # We want to loop over anyting found, so we get the latest (Which would be
  # lexicographically the last item)
done
export ORACLE_HOME
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH

NLS_LANG=AMERICAN_AMERICA.UTF8
NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
NLS_TIMESTAMP_FORMAT="YYYY-MM-DD HH24:MI:SS.FF6"

# Vim
if [ $(which vim) ]; then
  # have vim, use it
  export EDITOR=vim
  export VISUAL=vim
else
  # use plain vi
  export EDITOR=vi
  export VISUAL=vi
fi

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# If not running interactively, don't do anything more
# We use the : command to force a return code of 0
# otherwise "ssh host 'exit'" return a status code of 1
# It seems that the return 0 isn't really evaluated when
# the .bashrc file is evaluating before a command executed
# by ssh.
[[ $- =~ i ]] || { : ; return 0 ; }

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend
shopt -s cmdhist
shopt -s extglob
export HISTIGNORE="&:ls:lla:la:[bf]g:exit"

PROMPT_COMMAND='history -a'

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
# Make them available to other scripts
export COLUMNS LINES

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# vi edit mode
set -o vi

# make ctrl-s do forward history search like it's supposed to
stty -ixon

# This makes tmux behave better
if [[ $TERM == "xterm" ]]; then
  # Is TERM ever xterm and this is NOT valid?
  export TERM="xterm-256color"
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  # vte changed how it handles dim colors... I preferred 2;32 for dim green, but now I don't like it.
  # The old vte used specific indexes into the 256-color palette for dim colors:
  # how to use: 38;5;n
  # 2;30 = 16
  # 2;31 = 88
  # 2;32 = 28
  # 2;33 = 100
  # 2;34 = 18
  # 2;35 = 90
  # 2;36 = 30
  # 2;37 = 102

  PS1='${debian_chroot:+($debian_chroot)}\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]'
  if [[ $(type -t __git_ps1) == "function" ]]; then
    PS1=$PS1'$(__git_ps1 " (\[\033[38;5;28m\]%s\[\033[00m\])")'
  fi
  PS1=$PS1'\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

export GREP_OPTIONS="--exclude-dir=.svn"

# Better less defaults
export LESS=-FRXsS

#Don't log me out!
unset TMOUT

# Random envvars:
export SLANT_COLOUR_7=aaa9a5 SLANT_PRESETS="130x73 Hard:130x73dh"
export NET_COLOUR_4=000000
export NET_COLOUR_5=000000

# deb packaging stuff:
export DEBFULLNAME="Glenn Moss"
export DEBEMAIL="glennimoss+launchpad@gmail.com"

# Python rc
export PYTHONSTARTUP=~/.pythonrc.py

# Set up solarized color palette for linux console
if [[ $TERM == 'linux' ]]; then
  palette=(
    073642  # black
    dc322f  # red
    859900  # green
    b58900  # yellow
    268bd2  # blue
    d33682  # magenta
    2aa198  # cyan
    eee8d5  # base2
    002b36  # base03
    cb4b16  # orange
    586e75  # base01
    657b83  # base00
    839496  # base0
    6c71c4  # violet
    93a1a1  # base1
    fdf6e3  # base3
  )

  for ((i=0; i < ${#palette[@]}; i++)); do
    printf '\e]P%x%s\e\\' $i ${palette[$i]}
  done
fi

[[ -f $HOME/.bashrc_local ]] && source $HOME/.bashrc_local
