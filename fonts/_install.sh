if [[ $(uname -s) == Darwin* ]]; then
  base=$(dirname $BASH_SOURCE)
  cp $base/*.ttf ~/Library/Fonts
fi
