indent () {
  local amount=$1
  while IFS= read -r line; do
    echo "$amount$line"
  done
}

#--------------------------------------------------------------------------------------------------
# Adapted from http://github.com/fredpalmer/log4bash
# Copyright (c) Fred Palmer
# Licensed under the MIT license
#--------------------------------------------------------------------------------------------------

# Useful global variables that users may wish to reference
SCRIPT_ARGS=$@
SCRIPT_NAME=$0
SCRIPT_NAME=${SCRIPT_NAME#\./}
SCRIPT_NAME=${SCRIPT_NAME##/*/}
#SCRIPT_BASE_DIR=$(cd "$( dirname "$0")" && pwd )

declare -A LOG_LEVEL=(
[ERROR]=0
[WARNING]=1
[SUCCESS]=2
[INFO]=3
[DEBUG]=4
[TRACE]=5
)

# Set to 0 to only print commands in the command_log_* functions
LOG_COMMAND_EXEC=1

declare -A _log_color=(
[ERROR]="\e[1;31m"
[WARNING]="\e[33m"
[SUCCESS]="\e[2;32m"
[INFO]="\e[0m"
[DEBUG]="\e[35m"
[TRACE]="\e[1;35m"
)

_log_level_enabled () {
  if [[ ! $LOG_THRESHOLD ]]; then
    LOG_THRESHOLD=${LOG_LEVEL[SUCCESS]}
  fi
  if (( ${LOG_LEVEL[${1:-INFO}]} > $LOG_THRESHOLD )); then
    return 1
  fi
  return 0
}

_log () {
  local log_text=$1
  local log_level=${2:-INFO}

  _log_level_enabled $log_level || return 1

  echo -en "$(date +"%Y-%m-%d %H:%M:%S") ${_log_color[$log_level]}[${log_level}] "
  echo -n "${log_text}"
  echo -e "\e[0m"
  return 0
}

_command_log () {
  local level="$1"
  shift
  if _log_level_enabled $level; then
    local cmd
    printf -v cmd " %q" "$@"
    local disabled=
    if (( ! $LOG_COMMAND_EXEC )); then
      disabled="#"
    fi
    _log "$disabled${cmd:1}" "$level"
  fi
  if (( $LOG_COMMAND_EXEC )); then
    "$@"
  fi
}

log ()         { _log "$*"; }
log_info ()    { _log "$*" "INFO"; }
log_success () { _log "$*" "SUCCESS"; }
log_error ()   { _log "$*" "ERROR"; }
log_warning () { _log "$*" "WARNING"; }
log_debug ()   { _log "$*" "DEBUG"; }
log_trace ()   { _log "$*" "TRACE"; }

command_log ()         { _command_log ""        "$@"; }
command_log_info ()    { _command_log "INFO"    "$@"; }
command_log_success () { _command_log "SUCCESS" "$@"; }
command_log_error ()   { _command_log "ERROR"   "$@"; }
command_log_warning () { _command_log "WARNING" "$@"; }
command_log_debug ()   { _command_log "DEBUG"   "$@"; }
command_log_trace ()   { _command_log "TRACE"   "$@"; }

cat_log () {
  local log_level="${1:-INFO}"
  while IFS= read -r line; do
    _log "$line" $log_level
  done
}
