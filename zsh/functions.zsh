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
#   path_prepend <name_of_var> [path1 [path2 [path3]]]
#
# Example:
#   # Note the lack of '$' prefix to allow PATH to be 
#   # passed as indirect variable
#   path_prepend PATH "/usr/bin/"
#
# Params:
#   - <name_of_var> name of variable containing paths.
#   - path STRING path to prepend
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

# Fuzzy search and select on shell command history.
#
# On selection, the command will be pushed to the editing buffer stack, which allows edit
# on the command before running it. This will also allow the selected command to appear on the history
# rather than just the 'fhist'.
#
# Usage:
#   fhist
#
# Example:
#   fhist
fhist() {
	print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | sed -E 's/ *[0-9]*\*? *//' | fzf --height=40% --layout=reverse --border-label="Command History" --tac | sed -E 's/\\/\\\\/g')
}
