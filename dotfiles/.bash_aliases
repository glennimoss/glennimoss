#!/bin/bash

alias la='ls -a'
alias ll='ls -lh'
alias lld='ll -d'
alias lla='ll -a'
alias df='df -h'
alias du='du -h'
#alias less='less -XRs'                        # raw control characters
alias whence='type -a'                        # where, of a sort
alias diff='diff -u'
alias :e='vim'
alias hexdump='hexdump -C'
alias info='info --vi-keys'

if ! exists ack && exists ack-grep; then
  alias ack='ack-grep'
fi

if ! exists aws && exists aws2; then
  alias aws='aws2'
fi

# base conversions
radix_conv () {
  ibase=$1
  obase=$2
  shift 2
  while (( $# )); do
    N=$(echo ${1#0x}|tr '[:lower:]' '[:upper:]')
    shift
    ret=$(dc --expression="${obase}o${ibase}i${N}p")
    if [[ 2 == $obase ]]; then
      r=$(( ${#ret} + (8 - (${#ret} % 8)) % 8 ))
      ret=$(printf "%0${r}d\n" $ret)
    fi
    echo $ret
  done
}

maybe_stdin () {
  "$@" $(tty -s || cat -)
}

htob () {
  maybe_stdin radix_conv 16 2 "$@"
}

htod () {
  maybe_stdin radix_conv 16 10 "$@"
}
btoh () {
  maybe_stdin radix_conv 2 16 "$@"
}
btod () {
  maybe_stdin radix_conv 2 10 "$@"
}
dtoh () {
  maybe_stdin radix_conv 10 16 "$@"
}
dtob () {
  maybe_stdin radix_conv 10 2 "$@"
}

alias phing="phing -find build.xml"

alias gitdiff="git diff --no-index"

function svnpropdiff {
  if (( $# == 0 )); then
    echo "Usage:"
    echo "  svnpropdiff rev"
    echo "    diff properties between rev-1 and rev"
    echo "  svnpropdiff rev1 rev2"
    echo "    diff properties between rev1 and rev2"
    return 1
  fi
  pre=${${2:+${1}}:-$((${1} - 1))}
  post=${2:-${1}}
  diff -F '^  [^ ]' <(svn pl -v -r $pre .) <(svn pl -v -r $post .)
}

# If not running interactively, don't do anything more
[[ $- =~ i ]] || return 0

# enable color support of ls and also add handy aliases
if exists dircolors; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls -bF --color=auto'

fi

COMMON_GREP_OPTIONS="--exclude-dir=.svn"
$(grep --help 2>/dev/null | grep -- --color >/dev/null) && {
  #colorize grep matches with a nice yellow
  COMMON_GREP_OPTIONS+=" --color=auto"
}

# the LANG=C makes grep deal with multibyte chars better
alias grep="LANG=C grep $COMMON_GREP_OPTIONS"
alias fgrep="LANG=C fgrep $COMMON_GREP_OPTIONS"
alias egrep="LANG=C egrep $COMMON_GREP_OPTIONS"

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

[[ -f $HOME/.bash_aliases_local ]] && source $HOME/.bash_aliases_local
