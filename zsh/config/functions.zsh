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

