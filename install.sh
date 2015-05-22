#!/bin/bash

is () {
  return $1
}

if [[ -e $HOME/home_backup ]]; then
  echo $HOME/home_backup already exists. Deal with it before running this.
  exit 1
fi

mkdir "$HOME/home_backup"

shopt -s extglob nullglob

cd $(dirname $(readlink -f $0))

# Make dotfiles come first, as some other _install.sh scripts may depend on the
# configuration stored in dot files.
for topdir in dotfiles !(dotfiles); do
  if [[ -d $topdir ]]; then
    if [[ $topdir == 'dotfiles' ]]; then
      destdir=$HOME
    elif [[ ${topdir:0:1} == '_' ]]; then
      destdir=$HOME/.${topdir:1}
    else
      destdir=$HOME/$topdir
    fi
    if [[ ! -e $destdir ]]; then
      mkdir "$destdir"
    fi

    backup_dir=$HOME/home_backup/$topdir
    mkdir "$backup_dir"

    ignore=()
    whitelist=()

    cd "$topdir"
    srcdir=$(pwd)
    for file in _*; do
      srcfile=$srcdir/$file
      case $file in
        _install.sh)
          install_scripts+=("$srcfile")
          ;;
        _ignore)
          if (( ${#whitelist[@]} )); then
            echo "WARNING: You probably shouldn't use both $topdir/_ignore and $topdir/_whitelist"
          fi
          mapfile -t ignore < $srcfile
          ;;
        _whitelist)
          if (( ${#ignore[@]} )); then
            echo "WARNING: You probably shouldn't use both $topdir/_ignore and $topdir/_whitelist"
          fi
          mapfile -t whitelist < $srcfile
          ;;
        __pycache__)
          # ignored
          ;;
        *)
          echo Unknown specal file $file
          ;;
      esac
    done

    for file in !(.|..|_*); do
      process=1
      for pat in "${ignore[@]}"; do
        if [[ $file == $pat ]]; then
          process=0
        fi
      done
      process=$(( $process && ! ${#whitelist[@]} ))
      for pat in "${whitelist[@]}"; do
        if [[ $file == $pat ]]; then
          process=1
          break
        fi
      done

      srcfile=$srcdir/$file
      if [[ -L $srcfile ]]; then
        srcfile=$(readlink -f "$srcfile")
      fi
      destfile=$destdir/$file
      [[ $(readlink -f "$destfile") == $srcfile ]]; already_linked=$?

      if (( ! $process )); then
        if is $already_linked; then
          rm $destfile
        fi
        continue
      fi

      if is $already_linked; then
        continue
      fi
      if [[ -e $destfile || -L $destfile ]]; then
        mv "$destfile" "$backup_dir"
      fi
      ln -s "$srcfile" "$destfile"
    done

    # Clean up broken symlinks into this repo
    for file in $(find $destdir -maxdepth 1 -xtype l); do
      if [[ $(readlink $file) == $srcdir/* ]]; then
        rm $file
      fi
    done

    cd ..
    rmdir --ignore-fail-on-non-empty "$backup_dir"
  fi
done

for install_script in "${install_scripts[@]}"; do
  source "$install_script"
done

rmdir --ignore-fail-on-non-empty "$HOME/home_backup"

msg="Homedir's dotfiles are installed."
if [[ -e $HOME/home_backup ]]; then
  msg+=" Existing files are in ~/home_backup"
fi
echo $msg
