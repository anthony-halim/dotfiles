# Safely source argument if it exists
#
# Usage: 
#   safe_source <filename>
#
# Params:
#   - filename  STRING  path to file
safe_source() {
  [[ ! -e "$1" ]] || source "$1"
}

# Append paths to the given variable if it does not exist.
#
# Usage:
# path_append <name_of_var> [path1 [path2 [path3]]]
#
# Example:
#   # Note the lack of '$' prefix to allow PATH to be 
#   # passed as indirect variable
#   path_append PATH "/usr/bin/"
#
# Params:
#   - <name_of_var> name of variable containing paths.
#   - path STRING path to append
path_append() {
  for ARG in "${@:2}"
  do
    if [ -e "$ARG" ] && [[ ":${(P)1}:" != *":$ARG:"* ]]; then
      if [[ -z "${(P)1}" ]]; then
        export "$1=$ARG"
      else
        export "$1=${(P)1}:$ARG"
      fi
    fi
  done
}

# Prepend paths to the given variable if it does not exist.
#
# Usage:
# path_append <name_of_var> [path1 [path2 [path3]]]
#
# Example:
#   # Note the lack of '$' prefix to allow PATH to be 
#   # passed as indirect variable
#   path_append PATH "/usr/bin/"
#
# Params:
#   - <name_of_var> name of variable containing paths.
#   - path STRING path to append
path_prepend() {
  for ARG in "${@:2}"
  do
    if [ -e "$ARG" ] && [[ ":${(P)1}:" != *":$ARG:"* ]]; then
      if [[ -z "${(P)1}" ]]; then
        export "$1=$ARG"
      else
        export "$1=$ARG:${(P)1}"
      fi
    fi
  done
}
