# Generate random string that is URL safe and attempt to copy it to the clipboard.
# Optionally, we can include special characters; but resulting string will no longer be URL safe.
#
# For copying into the clipboard, we can provide explicit clipboard binary to use by using '-x'. 
# Else, we will attempt to check for common clipboards utility. 
# If every clipboard fail, we give up and print to the screen.
#
# Usage: 
#   genpw [--s, --special_char] [-l, --length <password_length>] [-x, --clipboard <clipboard binary to use>]
#
# Example:
#   # Generates random string with special characters, length of 24, and copied to clipboard using clip.exe.
#   genpw -s -l 24 -x clip.exe
#
# Flags/Options:
#   -s, --special_char  FLAG    whether to include special characters. Defaults to false.
#   -l, --length        INT     length of string to be generated. Defaults to 16.
#   -x, --clipboard     STRING  name of clipboard binary to use. If not provided, will attempt to use common clipboards.
genpw() {
  local use_special_char=0
  local pw_length=16 
  local clipboard_bin=""

  while :; do
    case "${1-}" in
    -s | --special_char) use_special_char=1 ;;
    -x | --clipboard) 
      clipboard_bin="${2-}"
      shift
      ;;
    -l | --length)
      pw_length="${2-}"
      shift
      ;;
    -?*) echo "Unknown option: $1" && return ;;
    *) break ;;
    esac
    shift
  done

  local generated_pw=""
  if [[ "${use_special_char}" -eq 1 ]]; then
    generated_pw=$(python -c "import secrets;import string;alphabets=string.ascii_letters+string.digits+string.punctuation;print(''.join([secrets.choice(alphabets) for n in range($pw_length)]));")
  else
    generated_pw=$(python -c "import secrets;import string;print(secrets.token_urlsafe($pw_length));")
  fi

  # Find clipboard binary
  if [[ -z "$clipboard_bin" ]]; then
    if [[ $(command -v clip.exe) ]]; then
      # WSL
      clipboard_bin="clip.exe"
    elif [[ $(command -v xclip) ]]; then
      # Gnome, MacOS
      clipboard_bin="xclip -sel clip"
    elif [[ $(command -v pbcopy) ]]; then
      # MacOS
      clipboard_bin="pbcopy"
    fi
  fi

  # Copy to clipboard
  if [[ $(command -v "$clipboard_bin") ]]; then
    # Use supplied binary if valid
    echo -n "$generated_pw" | "$clipboard_bin"
    echo "Copied to clipboard!"
  else
    echo "Unable to find clipboard. Here is your password anyway: $generated_pw"
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
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | sed -E 's/ *[0-9]*\*? *//' | fzf --height=40% --layout=reverse --border-label="Command History" +s --tac | sed -E 's/\\/\\\\/g')
}

# Fuzzy search on Kubernetes logs
# 
# Usage:
#   fkubectllogs [k8s_options...] k8s_logs_target
#
# Example:
#   fkubectllogs --context target_context --namespace target_namespace deployment/target_deployment
#   fkubectllogs --context target_context --namespace target_namespace target_pod
fkubectllogs() {
  local opts="--follow --tail=10000 $@"
  local cmd="kubectl logs $opts"
  fzf \
    --height=60% --info=inline --layout=reverse \
    --border-label="Fuzzy Search Kubernetes Logs - Opts: $opts" \
    --bind="start:reload:($cmd)" \
    --preview="echo {} | logfilter" --preview-window=right,wrap
}

# Fuzzy search on Kubernetes pods status
#
# Usage:
#   fkubectlpods k8s_resource [k8s_options...]
#
# Example:
#   fkubectlpods deployment --context target_context --namespace target_namespace
#   fkubectlpods statefulsets --context target_context --namespace target_namespace
fkubectlpods() {
  local all_args=("$@")
  local resource_type="$1"
  local kubectl_opts=("${all_args[@]:1}")
  local cmd="kubectl get $resource_type -L app --no-headers $kubectl_opts"
  fzf \
    --height=60% --info=inline --layout=reverse \
    --border-label="Fuzzy Search Kubernetes Live Pods - Opts: $all_args" \
    --bind "start:reload:($cmd)" \
    --preview="kubectl get pods $kubectl_opts --selector=app={6} --watch=true" --preview-window=right,follow
}

