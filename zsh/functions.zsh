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

## Budget version of z: https://github.com/rupa/z

# Global in-memory cache for bookmarks
typeset -a _goto_cache_lines

# Bookmarks current directory.
#
# Usage: 
#   bm [-r, --remove] [--remove-all]
#
# Example:
#   # bookmark current directory
#   bm
#
# Flags/Options
#       --remove-all    FLAG    clear all bookmarked directories. 
bm () {
  local directory_cache="${ZSH_DIRJUMP:-$HOME/.cache/.dirjump}"
  local purge_cache_mode=false

  while :; do
    case "${1-}" in
    --remove-all) purge_cache_mode=true ;;
    -?*) echo "Unknown option: $1" && return ;;
    *) break ;;
    esac
    shift
  done

  # Purge cache
  if [[ "$purge_cache_mode" = true ]]; then
    [[ -f "${directory_cache}" ]] && {
      rm -rf "${directory_cache}" && echo "-> Removed cache: ${directory_cache}" 
    }
    _goto_cache_lines=() # Clear in-memory cache
    return
  fi

  [[ -f "${directory_cache}" ]] || touch "${directory_cache}"
  local grep_found=$(grep -E ${PWD}'$' "${directory_cache}")
  if [[ -n "$grep_found" ]]; then
    echo "-> ${PWD} is already bookmarked"
  else
    echo "$PWD" >> "${directory_cache}"
    echo "-> ${PWD} bookmarked"
    _goto_cache_lines=() # Reset memory cache to force re-read
  fi
}

# Go to (goto) directory saved in the list of bookmarks. If there is conflicting names, will spawn fzf window.
#
# Usage:
#   goto <dir_name>
#
# Example:
#   # foo is partial/full name of path to directory
#   goto foo
goto () {
  local directory_cache="${ZSH_DIRJUMP:-$HOME/.cache/.dirjump}"
  local q="$*"

  # go to $HOME if argument is empty or just empty spaces
  if [[ -z "${q// }" ]]; then
    cd "$HOME"
    return
  fi

  # Lazy-load cache lines from disk once per session (or after a `bm` update)
  if (( $#_goto_cache_lines == 0 )); then
    if [[ -f "${directory_cache}" ]]; then
      _goto_cache_lines=( ${(f)"$(< "${directory_cache}")"} )
    fi
  fi

  # Split user input into query terms
  local -a terms
  terms=( $=q )

  # Filter lines that contain ALL query terms (case-insensitive substring)
  local -a matches
  matches=( "${_goto_cache_lines[@]}" )
  setopt local_options extended_glob
  for term in "${terms[@]}"; do
    matches=( ${(M)matches:#(#i)*${term}*} )
  done

  # Handle the match count. If it's exactly one match, we avoid
  # spawning fzf and directly go to the directory. Else, we spawn fzf.
  if (( $#matches == 1 )); then
    # Exactly one match -> go directly (0ms, no process spawning!)
    cd "${matches[1]}"
  else
    cd "$(fzf --height=25% --layout=reverse --border-label="Go to" -1 +m -q "$q" < "${directory_cache}")"
  fi
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
