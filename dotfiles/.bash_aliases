#!/bin/bash

alias la='ls -a'
alias ll='ls -lh'
alias lld='ll -d'
alias lla='ll -a'
alias df='df -h'
alias du='du -h'
alias less='less -XRs'                        # raw control characters
alias whence='type -a'                        # where, of a sort
alias diff='diff -u'
alias :e='vim'
alias go='gnome-open'
alias hexdump='hexdump -C'
alias ack='ack-grep'

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


$(grep --help 2>/dev/null | grep -- --color >/dev/null) && {
  #colorize grep matches with a nice yellow
  # the LANG=C makes grep deal with multibyte chars better
  alias grep='GREP_COLOR="1;33" LANG=C grep --color=auto --exclude-dir=.svn';
} || {
  # the LANG=C makes grep deal with multibyte chars better
  alias grep='LANG=C grep --exclude-dir=.svn';
}

alias phing="phing -find build.xml"

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
[[ $- =~ i ]] || return

$(ls --help 2>/dev/null | grep -- --color= >/dev/null) && {
  alias ls='ls -bF --color=auto' #yea! color!
}

alias sqlplus="$HOME/.sqlplus/sqlplus.sh"
