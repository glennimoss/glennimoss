if exists fc-list && exists fc-cache; then
  fc-list | grep -q ProggyTinyGIM || fc-cache -f -v $HOME/.fonts
fi
