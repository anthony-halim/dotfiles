## Budget version of z: https://github.com/rupa/z

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
  local directory_cache="${(P)ZSH_DIRJUMP:-$HOME/.cache/dirjump}"
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
    return
  fi

  [[ -f "${directory_cache}" ]] || touch "${directory_cache}"
  local grep_found=$(grep -E ${PWD}'$' "${directory_cache}")
  if [[ -n "$grep_found" ]]; then
    echo "-> ${PWD} is already bookmarked"
  else
    echo "$PWD" >> "${directory_cache}"
    echo "-> ${PWD} bookmarked"
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
  local directory_cache="${(P)ZSH_DIRJUMP:-$HOME/.cache/dirjump}"
  q=" $*"
  q=${q// -/ !}

  # allows typing "to foo -bar", which becomes "foo !bar" in the fzf query
  cd "$(fzf -1 +m -q "$q" < "${directory_cache}")"
}
