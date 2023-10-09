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
# String will be plain printed to the screen.
# usage: genpw [--s, --special_char] [-l, --length <password_length>]
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
    -?*) echo "Unknown option: $1" && return ;;
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

## budget version of zsh-z: bm & to
# usage: bm (bookmark current directory)
bm () {
  local directory_cache="${(P)ZSH_DIRJUMP:-$HOME/.cache/dirjump}"
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
  local directory_cache="${ZSH_DIRJUMP:-$HOME/.cache/dirjump}"
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

# Open todo notes
# usage: ntodo

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

  bash -c "git -C '$vault_path' commit -am '$commit_message' && git -C '$vault_path' push $git_upstream $git_branch"
  
  echo "Success!"
}
