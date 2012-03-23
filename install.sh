#!/bin/bash

if [[ ! -e bin || ! -e dotfiles ]]; then
  echo This must be run from the directory of this script.
  exit 1
fi

if [[ -e $HOME/home_backup ]]; then
  echo $HOME/home_backup already exists. Deal with it before running this.
  exit 1
fi

mkdir $HOME/home_backup

for topdir in *; do
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
      if [[ $file != '.' && $file != '..' && $file != '*' && $file != '.*' ]]; then
        srcfile=$(pwd)/$file
        destfile=$dir/$file
        if [[ -e $destfile ]]; then
          if [[ $(realpath "$destfile") == $srcfile ]]; then
            continue
          fi
          mv $destfile $backup_dir
        fi
        ln -s $srcfile $dir
      fi
    done
    cd ..
    rmdir --ignore-fail-on-non-empty $backup_dir
  fi
done
rmdir --ignore-fail-on-non-empty $HOME/home_backup

msg="Homedir\'s dotfiles are installed."
if [[ -e $HOME/home_backup ]]; then
  msg="$msg Existing files are in ~/home_backup"
fi
echo $msg
