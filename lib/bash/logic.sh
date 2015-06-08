is () {
  return $1
}


# Convert a command return code to a boolean.
#
# Usage:
#   boolvar=$([[ $a == $b ]]; bool)
#   if $boolvar; then
#     ...
#   fi
bool () {
  (( ! $? )) && echo true || echo false
}
notbool () {
  (( $? )) && echo true || echo false
}
