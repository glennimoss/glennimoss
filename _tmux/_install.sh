[[ -d $HOME/.tmux/plugins/tpm ]] || {
  tmux_ver=$(tmux -V)
  if [[ $tmux_ver == "tmux 2.0" ]]; then
    mkdir -p $HOME/.tmux/plugins
    git clone git@github.com:tmux-plugins/tpm $HOME/.tmux/plugins/tpm

    tmux new-session -d -s install-plugins
    $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh
    tmux kill-session -t install-plugins
  else
    log_warning "Requires tmux 2.0 (found $tmux_ver)"
  fi
  unset tmux_ver
}
