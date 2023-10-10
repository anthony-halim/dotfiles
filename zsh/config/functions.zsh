# Safely source argument if it exists
# usage: safe_source <filename>
safe_source() {
  [[ ! -e "$1" ]] || source "$1"
}

# Load local plugin
# usage: zsh_load_local_plugin <plugin_name> <plugin_source>
zsh_load_local_plugin() {
  local plugin_name="$1"
  local plugin_source="$2"
  local plugin_dir="${(P)ZSH_PLUGIN:-$HOME/.config/zsh/plugin}"

  safe_source "$plugin_dir/$plugin_name/$plugin_source"
}

# Generate random string, optionally use special characters.
#
# String will be copied into the clipboard.
# Will attempt to check for common clipboards utility. Alternatively, you can pass the clipboard binary directly.
# If every clipboard fail, we give up and print to the screen.
#
# usage: genpw [--s, --special_char] [-l, --length <password_length>] [-x, --clipboard <clipboard binary to use>]
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

## budget version of zsh-z: bm & to
# bookmark current directory
# usage: bm (bookmark current directory)
bm () {
  local directory_cache="${(P)ZSH_DIRJUMP:-$HOME/.cache/dirjump}"
  [[ -f "${directory_cache}" ]] || touch "${directory_cache}"

  if grep -E ${PWD}'$' "${directory_cache}" 
  then
      echo "-> ${PWD} is already bookmarked"
  else
      echo "$PWD" >> "${directory_cache}"
      echo "-> ${PWD} bookmarked"
  fi
}

# fast travel to directory saved in the list of bookmark.
# If there is conflicting names, will spawn fzf window.
# e.g. to <dir_name> (fuzzy search)
# usage: to foo (foo is the partial/full name of directory)
to () {
  local directory_cache="${(P)ZSH_DIRJUMP:-$HOME/.cache/dirjump}"
  q=" $*"
  q=${q// -/ !}

  # allows typing "to foo -bar", which becomes "foo !bar" in the fzf query
  cd "$(fzf -1 +m -q "$q" < "${directory_cache}")"
}

## Note taking related

# Open daily notes in Neovim
# usage: ndaily
ndaily() {
  nvim +'Telekasten goto_today'
}

# Open weekly notes
# usage: nweekly
nweekly() {
  nvim +'Telekasten goto_thisweek'
}

# Find notes
# usage: nfind
nfind() {
  nvim +'Telekasten find_notes'
}

# Search notes (grep)
# usage: ngrep
ngrep() {
  nvim +'Telekasten search_notes'
}

# Find notes tags
# usage: ntags
ntags() {
  nvim +'Telekasten show_tags'
}

# Git commit notes and update to git upstream and git branch.
# By default, will git commit NOTES_DEFAULT_VAULT notes vault to origin main.
#
# usage: ncommit [-m, --message <commit_message>] 
#                [-v, --vault <vault_type>] [-p, --path <vault_path]
#                [-u <git_upstream> ] [-b <git_branch> ]
ncommit() {
  local hdate=$(date +"%D %T")
  local commit_message="Notes upload - ${hdate}"

  local chosen_vault=${(P)NOTES_DEFAULT_VAULT:-personal}
  local personal_vault_path=${(P)NOTES_PERSONAL_VAULT:-$HOME/notes/personal}
  local work_vault_path=${(P)NOTES_WORK_VAULT:-$HOME/notes/work}
  local vault_path=""

  local git_upstream="origin"
  local git_branch="main"

  while :; do
    case "${1-}" in
    -m | --message)
      commit_message="${2-}"
      shift
      ;;
    -v | --vault)
      chosen_vault="${2-}"
      shift
      ;;
    -p | --path)
      vault_path="${2-}"
      shift
      ;;
    -u | --upstream)
      git_upstream="${2-}"
      shift
      ;;
    -b | --branch)
      git_branch="${2-}"
      shift
      ;;
    -?*) echo "Unknown option: $1" && return ;;
    *) break ;;
    esac
    shift
  done

  if [[ -z "$vault_path" ]]; then
    if [[ "${chosen_vault}" =~ ^personal ]]; then
      vault_path="${personal_vault_path}"
    elif [[ "${chosen_vault}" =~ ^work ]]; then
      vault_path="${work_vault_path}"
    else
      echo "Unable to get path to vault!"
      return
    fi
  fi

  echo "Commiting notes:"
  echo "  -> Hault: $vault_path"
  echo "  -> Commit message: $commit_message"
  echo "  -> Git upstream: $git_upstream"
  echo "  -> Git branch: $git_branch"

  bash -c "git -C '$vault_path' add . && git -C '$vault_path' commit -m '$commit_message' && git -C '$vault_path' push $git_upstream $git_branch"
  
  echo "Success!"
}
