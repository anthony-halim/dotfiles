# Set directories
export ZSH="${HOME}/.config/zsh"
export ZSH_PLUGIN="${ZSH}/plugin"
ZSH_CUSTOM="${ZSH}/custom"
ZSH_CONFIG="${ZSH}/config"
ZSH_LOCAL_CONFIG="${ZSH}/local_config"
ZSH_HISTORY_CACHE="${HOME}/.cache/.zsh_history"

# Load requirements, fail if files not found
source "${ZSH_CONFIG}/functions/utils.zsh"
source "${ZSH_CONFIG}/exports.zsh"

# If there is local export file, load it first
safe_source "${ZSH_LOCAL_CONFIG}/exports.zsh"

# Auto start zellij
if [[ $(command -v zellij) && "$ZELLIJ_AUTO_START" = true ]]; then
  # From 'eval "$(zellij setup --generate-auto-start zsh)"'
  if [[ -z "$ZELLIJ" ]]; then
      if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
          zellij attach -c
      else
          zellij 
      fi
  fi
fi

# Enable zap
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

# Enable colors
autoload -Uz colors && colors

# Allow comments as suffix to commands e.g. echo test # test
setopt interactive_comments

# History setup
setopt SHARE_HISTORY
HISTFILE="$ZSH_HISTORY_CACHE"
SAVEHIST=10000
HISTSIZE=9999
setopt HIST_EXPIRE_DUPS_FIRST

# Load add on functions
safe_source "${ZSH_CONFIG}/functions/autocompletion.zsh"
safe_source "${ZSH_CONFIG}/functions/budget_z.zsh"
safe_source "${ZSH_CONFIG}/functions/pw.zsh"
safe_source "${ZSH_CONFIG}/functions/notes.zsh"
safe_source "${ZSH_CONFIG}/functions/zellij_utils.zsh"

# Load plugins
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "zsh-users/zsh-history-substring-search"
plug "zap-zsh/sudo"
plug "zap-zsh/web-search"
plug "jeffreytse/zsh-vi-mode"

# Bindkeys includes plugin keymaps, so must be done after plugin load
safe_source "${ZSH_CONFIG}/bindkeys.zsh"

# Load aliases
safe_source "${ZSH_CONFIG}/aliases.zsh"

# Load local config files
if [[ -d "${ZSH_LOCAL_CONFIG}" ]]
then 
  for conf in "${ZSH_LOCAL_CONFIG}/"*.zsh(.N); do
    source "${conf}"
  done
  unset conf
fi

# Register tab name update for zellij
zellij_tab_name_update_by_git_repo
chpwd_functions+=(zellij_tab_name_update_by_git_repo)

# Enable starship
[[ -f "${STARSHIP_CONFIG:-$HOME/.config/starship.toml}" ]] && eval "$(starship init zsh)"

