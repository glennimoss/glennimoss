while true; do
  fname=$(lsof * | awk '{ if (substr($4, length($4)) ~ "[wu]") { print $9; }; }')
  if [[ $fname ]]; then
    size=$(du -h $fname)
    if [[ $size != $last ]]; then
      echo
      echo -n $size ' '
    else
      echo -n .
    fi
    last=$size
  fi
done
