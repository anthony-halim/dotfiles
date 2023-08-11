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
