#!/bin/bash

if [[ ! -d bin || ! -d dotfiles ]]; then
  echo This must be run from the directory of this script.
  exit 1
fi

if [[ -e $HOME/home_backup ]]; then
  echo $HOME/home_backup already exists. Deal with it before running this.
  exit 1
fi

mkdir $HOME/home_backup

# Save current extglob setting
old_extglob=$(shopt -p extglob)
shopt -s extglob

# Make dotfiles come first, as some other _install.sh scripts may depend on the
# configuration stored in dot files.
for topdir in dotfiles !(dotfiles); do
  if [[ -d $topdir ]]; then
    if [[ $topdir == 'dotfiles' ]]; then
      dir=$HOME
    elif [[ ${topdir:0:1} == '_' ]]; then
      dir=$HOME/.${topdir:1}
    else
      dir=$HOME/$topdir
    fi
    if [[ ! -e $dir ]]; then
      mkdir $dir
    fi

    backup_dir=$HOME/home_backup/$topdir
    mkdir $backup_dir

    cd $topdir
    for file in * .*; do
      srcfile=$(pwd)/$file
      if [[ $file == '_install.sh' ]]; then
        install_scripts[${#install_scripts[@]}]=$srcfile
      elif [[ $file != '.' && $file != '..' && $file != '*' && $file != '.*' ]]; then
        if [[ -L $srcfile ]]; then
          srcfile=$(readlink -f "$srcfile")
        fi
        destfile=$dir/$file
        if [[ $(readlink -f "$destfile") == $srcfile ]]; then
          continue
        fi
        if [[ -e $destfile || -L $destfile ]]; then
          mv $destfile $backup_dir
        fi
        ln -s $srcfile $destfile
      fi
    done
    cd ..
    rmdir --ignore-fail-on-non-empty $backup_dir
  fi
done

for install_script in "${install_scripts[@]}"; do
  source "$install_script"
done

rmdir --ignore-fail-on-non-empty $HOME/home_backup

# Reset extglob setting
$old_extglob

msg="Homedir's dotfiles are installed."
if [[ -e $HOME/home_backup ]]; then

  msg="$msg Existing files are in ~/home_backup"
fi
echo $msg
