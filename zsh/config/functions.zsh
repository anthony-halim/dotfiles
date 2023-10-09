safe_source() {
  [[ ! -e "$1" ]] || source "$1"
}

# Load local plugin
zsh_load_local_plugin() {
  local plugin_name="$1"
  local plugin_source="$2"
  local plugin_dir="${ZSH_PLUGIN:-$HOME/.config/zsh/plugin}"

  safe_source "$plugin_dir/$plugin_name/$plugin_source"
}

genpw() {
  local use_special_char=0
  local pw_length=16 

  while :; do
    case "${1-}" in
    -s | --special_char) use_special_char=1 ;;
    -l | --length)
      pw_length="${2-}"
      shift
      ;;
    *) break ;;
    esac
    shift
  done

  if [[ "${use_special_char}" -eq 1 ]]; then
    python -c "import secrets;import string;alphabets=string.ascii_letters+string.digits+string.punctuation;print(''.join([secrets.choice(alphabets) for n in range($pw_length)]));"
  else
    python -c "import secrets;import string;print(secrets.token_urlsafe($pw_length));"
  fi
}

## budget version of zsh-z

# usage: bm (bookmark current directory)
bm () {
  local directory_cache="${HOME}/.cache/dirjump"
  [[ -f "${directory_cache}" ]] || touch "${directory_cache}"

  if grep -E ${PWD}'$' "${directory_cache}" 
  then
      echo "${PWD} is already bookmarked"
  else
      echo "$PWD" >> "${directory_cache}"
      echo "${PWD} bookmarked"
  fi
}

# fast travel to directory saved in the list of bookmark
# usage: to foo (foo is the partial/full name of directory)
to () {
  local directory_cache="${HOME}/.cache/dirjump"
  q=" $*"
  q=${q// -/ !}

  # allows typing "to foo -bar", which becomes "foo !bar" in the fzf query
  cd "$(fzf -1 +m -q "$q" < "${directory_cache}")"
}
