#!/usr/bin/env bash

exists () {
  hash "$1" &> /dev/null
}

if [[ $(uname -s) == Darwin* ]] && ! exists brew; then
  if [[ ! -x /opt/homebrew/bin/brew ]]; then
    echo Installing homebrew...
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ ! -x /opt/homebrew/bin/brew ]]; then
      echo Homebrew not found. Did installation fail?
      exit 3
    fi
    echo Homebrew installed.
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo Installing homebrew staples...
  brew install alacritty bash bash-completion@2 coreutils git gnu-sed gnu-tar go jq puzzles tmux vim xdot
  echo Setting shell for $USER to /opt/homebrew/bin/bash ...
  sudo chsh -s /opt/homebrew/bin/bash $USER
  $0
  exit 0
fi

if (( ${BASH_VERSINFO[0]} < 4 )); then
  echo "This requires Bash 4 or later."
  exit 100
fi

if ! exists realpath; then
  echo 'Command `realpath` not found. Please install coreutils.'
  exit 101
fi

# OS-specific workarounds
case $(uname -s) in
  MINGW*)
    export MSYS=winsymlinks:nativestrict
    ;;
esac

cd -P $(dirname "$0")
ROOT=$(pwd -P)

source lib/bash/logging.sh
source lib/bash/logic.sh

if [[ $1 == "-h" || $1 == "--help" ]]; then
  echo "Usage: $0 [-dLEVEL]"
  echo "Install all user configuration."
  echo "  -dLEVEL    Set loging level to LEVEL (One of: TRACE, DEBUG, INFO, SUCCESS, WARNING, ERROR)"
  echo "             If LEVEL is not specified, DEBUG is used."
  exit 0
fi


loglevel=INFO
if [[ $1 == -d* ]]; then
  loglevel=${1:2}
  if [[ ! $loglevel ]]; then
    loglevel=DEBUG
  fi
fi

LOG_THRESHOLD=${LOG_LEVEL[$loglevel]}

if [[ -e $HOME/home_backup ]]; then
  log_error "$HOME/home_backup already exists. Deal with it before running this."
  exit 1
fi

shopt -s extglob nullglob dotglob

make_destname () {
  if [[ ! $1 ]]; then
    return
  fi

  local dir=$(dirname "$1")
  local base=$(basename "$1")

  if [[ ${base:0:1} == '_' ]]; then
    base=.${base:1}
  fi

  if [[ $dir != '.' ]]; then
    base=$(make_destname "$dir")/$base
  fi


  echo "$base"
}


install () {
  local recursive_depth=0
  local recursive=false
  if [[ $1 == -r* ]]; then
    recursive=true
    recursive_depth=${1#-r}
    shift
  fi

  local srcroot=$1
  local destroot=${2-$(make_destname $1)}
  local backup_dir=$HOME/home_backup/$destroot

  log_debug "install: recursive=$recursive (depth: $(( recursive_depth ))) srcroot=$srcroot destroot=$destroot"

  local ignore=()
  local whitelist=()
  local srcfile

  pushd "$ROOT/$srcroot" >/dev/null
  local srcdir=$(pwd)
  local destdir=$HOME/$destroot
  log_debug "srcdir=$srcdir desdir=$destdir"
  for file in _*; do
    srcfile=$srcdir/$file
    case $file in
      _install.sh)
        install_scripts+=("$srcfile")
        ;;
      _ignore)
        if (( ${#whitelist[@]} )); then
          log_warning "WARNING: You probably shouldn't use both $srcroot/_ignore and $srcroot/_whitelist"
        fi
        mapfile -t ignore < "$srcfile"
        ;;
      _whitelist)
        if (( ${#ignore[@]} )); then
          log_warning "WARNING: You probably shouldn't use both $srcroot/_ignore and $srcroot/_whitelist"
        fi
        mapfile -t whitelist < "$srcfile"
        ;;
      __pycache__)
        # ignored
        ;;
      *)
        log_warning "Unknown special file $file"
        ;;
    esac
  done
  ignore+=(.gitignore)

  for file in !(.|..|_*); do
    log_trace "looking at $srcroot/$file"
    #git check-ignore -q $file; local process=$? # Returns 0 if the file is ignored, or 1 otherwise
    local process=$(git check-ignore -q "$file"; notbool) # Returns 0 if the file is ignored, or 1 otherwise
    #if (( $process )); then
    if $process; then
      for pat in "${ignore[@]}"; do
        if [[ $file == $pat ]]; then
          #process=0
          process=false
          log_debug "Blacklisted: $file"
        fi
      done
    fi
    #process=$(( $process && ! ${#whitelist[@]} ))
    process=$( $process && (( ! ${#whitelist[@]} )); bool)
    for pat in "${whitelist[@]}"; do
      if [[ $file == $pat ]]; then
        #process=1
        process=true
        log_debug "Whitelisted: $file"
        break
      fi
    done

    srcfile=$srcdir/$file
    if [[ -L $srcfile ]]; then
      srcfile=$(realpath "$srcfile")
    fi
    local destfile=$destdir/$file
    local already_linked=$([[ $(realpath -q "$destfile") == $srcfile ]]; bool)

    if [[ -d $srcfile ]] && $recursive; then
      # Remove existing shallow linking
      if $already_linked; then
        command_log_trace rm "$destfile"
      fi

      install -r$(( $recursive_depth + 1 )) "$srcroot/$file" #| indent "  "
      continue
    fi


    #if (( ! $process )); then
    if ! $process; then
      log_trace "Not processing $srcfile"
      if $already_linked; then
        log_info "Removing ignored file $destfile"
        command_log_trace rm "$destfile"
      fi
      continue
    fi

    if $already_linked; then
      log_trace $srcfile is already linked
      continue
    fi
    if [[ -e $destfile || -L $destfile ]]; then
      command_log_trace mkdir -p "$backup_dir"
      command_log_trace mv "$destfile" "$backup_dir"
    fi
    command_log_trace mkdir -p "$destdir"
    command_log_trace ln -s "$srcfile" "$destfile"
  done

  # Clean up broken symlinks into this repo only on top-level dirs.
  if [[ -d $destdir ]] && (( recursive_depth == 0 )); then
    depth="-maxdepth 1"
    if $recursive; then
      depth=
    fi
    log_debug "Clean up broken symlinks in $destdir using ${depth:-no depth restriction}"
    while read -d $'\0' -r file; do
      if [[ $(realpath -m "$file") == $srcdir/* ]]; then
        log_info "Removing broken symlink $file"
        command_log_trace rm "$file"
        command_log_trace rmdir -p --ignore-fail-on-non-empty "$(dirname "$file")" 2>/dev/null
      fi
    done < <(find -L "$destdir" $depth -type l -print0 2>/dev/null)
  fi

  popd >/dev/null
  if [[ -d $backup_dir ]]; then
    rmdir --ignore-fail-on-non-empty "$backup_dir"
  fi
}

# Make dotfiles come first, as some other _install.sh scripts may depend on the
# configuration stored in dot files.
log_info Installing dotfiles
install dotfiles ""

while read -d $'\0' -r topdir; do
  topdir=${topdir#./}
  log_info Installing $topdir
  install -r "$topdir"
done < <(find . -maxdepth 1 -type d \! \( -name dotfiles -o -name '.*' \) -print0 )

for install_script in "${install_scripts[@]}"; do
  command_log_info source "$install_script"
done

if [[ -d $HOME/home_backup ]]; then
  rmdir --ignore-fail-on-non-empty "$HOME/home_backup"
fi

msg="Homedir's dotfiles are installed."
if [[ -e $HOME/home_backup ]]; then
  msg+=" Existing files are in ~/home_backup"
fi
log_success $msg
exit
