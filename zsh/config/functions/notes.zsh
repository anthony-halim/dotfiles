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

