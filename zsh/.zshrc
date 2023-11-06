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
# NOTE: Must be done before p10k setup (instant prompt and actual sourcing)
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

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
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
plug "romkatv/powerlevel10k"
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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# NOTE: We leave p10k config in default location to allow p10k to modify it normally
[[ ! -f "${HOME}/.p10k.zsh" ]] || source "${HOME}/.p10k.zsh" 
