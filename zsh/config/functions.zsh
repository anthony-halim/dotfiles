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

# Load local plugin from the plugin_name and plugin_source.
#
# Usage: 
#   zsh_load_local_plugin <plugin_name> <plugin_source>
# 
# Example:
#   zsh_load_local_plugin "zsh-autosuggestions" "zsh-autosuggestions.zsh"
#
# Params:
#   - plugin_name     STRING            refers to the name of plugin, e.g. zsh-syntax-highlighting
#   - plugin_source   STRING            refers to the path to entry point of the plugin, e.g. zsh-syntax-highlighting.zsh
#   - plugin_dir      ENV:$ZSH_PLUGIN   directory to find the plugin_dir from. Fetched via environment variable: $ZSH_PLUGIN. Defaults to ${HOME}/.config/zsh/plugin
zsh_load_local_plugin() {
  local plugin_name="$1"
  local plugin_source="$2"
  local plugin_dir="${(P)ZSH_PLUGIN:-$HOME/.config/zsh/plugin}"

  safe_source "$plugin_dir/$plugin_name/$plugin_source"
}

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

## Budget version of z: https://github.com/rupa/z

# Bookmark current directory.
#
# Usage: 
#   bm
#
# Example:
#   # bookmark current directory
#   bm
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

# Go to (gt) directory saved in the list of bookmarks. If there is conflicting names, will spawn fzf window.
#
# Usage:
#   gt <dir_name>
#
# Example:
#   # foo is partial/full name of path to directory
#   gt foo
gt () {
  local directory_cache="${(P)ZSH_DIRJUMP:-$HOME/.cache/dirjump}"
  q=" $*"
  q=${q// -/ !}

  # allows typing "to foo -bar", which becomes "foo !bar" in the fzf query
  cd "$(fzf -1 +m -q "$q" < "${directory_cache}")"
}

## Note taking related

# Open daily notes in Neovim
# Usage: ndaily
ndaily() {
  nvim +'Telekasten goto_today'
}

# Open weekly notes
# Usage: nweekly
nweekly() {
  nvim +'Telekasten goto_thisweek'
}

# Find notes
# Usage: nfind
nfind() {
  nvim +'Telekasten find_notes'
}

# Search notes (grep)
# Usage: ngrep
ngrep() {
  nvim +'Telekasten search_notes'
}

# Find notes tags
# Usage: ntags
ntags() {
  nvim +'Telekasten show_tags'
}

# Create new note
# Usage: nnew
nnew() {
  nvim +'Telekasten new_note'
}

# Create new templated note
# Usage: ntmplnew
ntmplnew() {
  nvim +'Telekasten new_templated_note'
}

# Git commit notes and update to git upstream and git branch.
# By default, will git commit NOTES_DEFAULT_VAULT notes vault to git origin/main.
#
# Usage: 
#   ncommit [-m, --message <commit_message>] 
#           [-v, --vault <vault_type>] [-p, --path <vault_path]
#           [-u <git_upstream> ] [-b <git_branch> ]
#
# Example:
#   # Commit default vault with -m "custom message" to "chore-branch" branch in default upstream
#   ncommit -m "custom message" -b "chore-branch"
#
# Flags/Options:
#   -m, --message       STRING                                          commit message. Defaults to 'Notes upload - $TIMESTAMP'
#   -v  --vault         ENV:$NOTES_DEFAULT_VAULT:("personal"|"work")    type of vault. If environment variable is not present, defaults to "personal".
#   -p, --path          STRING                                          path to vault. Will overrides --vault.
#   -u, --upstream      STRING                                          git upstream to commit to. Defaults to "origin".
#   -b, --branch        STRING                                          git branch to commit to. Defaults to "main".
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

# Git pull (with --rebase) notes and update from git upstream and git branch.
# By default, will git pull NOTES_DEFAULT_VAULT notes vault from git origin/main.
#
# Usage: 
#   npull [-v, --vault <vault_type>] [-p, --path <vault_path]
#         [-u <git_upstream> ] [-b <git_branch> ]
#
# Example:
#   # Pull default vault with from "chore-branch" branch in default upstream
#   npull  -b "chore-branch"
#
# Flags/Options:
#   -v  --vault         ENV:$NOTES_DEFAULT_VAULT:("personal"|"work")    type of vault. If environment variable is not present, defaults to "personal".
#   -p, --path          STRING                                          path to vault. Will overrides --vault.
#   -u, --upstream      STRING                                          git upstream to commit to. Defaults to "origin".
#   -b, --branch        STRING                                          git branch to commit to. Defaults to "main".
npull() {
  local chosen_vault=${(P)NOTES_DEFAULT_VAULT:-personal}
  local personal_vault_path=${(P)NOTES_PERSONAL_VAULT:-$HOME/notes/personal}
  local work_vault_path=${(P)NOTES_WORK_VAULT:-$HOME/notes/work}
  local vault_path=""

  local git_upstream="origin"
  local git_branch="main"

  while :; do
    case "${1-}" in
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

  echo "Pulling notes:"
  echo "  -> Hault: $vault_path"
  echo "  -> Git upstream: $git_upstream"
  echo "  -> Git branch: $git_branch"

  bash -c "git -C '$vault_path' pull --rebase $git_upstream $git_branch"
  
  echo "Success!"
}
