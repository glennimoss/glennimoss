[[ -d $HOME/.tmux/plugins/tpm ]] || {
  mkdir -p $HOME/.tmux/plugins
  git clone git@github.com:tmux-plugins/tpm $HOME/.tmux/plugins/tpm

  tmux new-session -d -s install-plugins
  $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh
  tmux kill-session -t install-plugins
}
