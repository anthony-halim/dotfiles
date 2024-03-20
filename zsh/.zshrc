# Set directories
export ZSH="${HOME}/.config/zsh"
export ZSH_PLUGIN="${ZSH}/plugin"
ZSH_CUSTOM="${ZSH}/custom"
ZSH_CONFIG="${ZSH}/config"
ZSH_LOCAL_CONFIG="${ZSH}/local_config"
ZSH_HISTORY_CACHE="${HOME}/.cache/.zsh_history"

# Load requirements, fail if files not found
source "${ZSH_CONFIG}/functions/utils.zsh"
source "${ZSH_CONFIG}/functions/zellij_utils.zsh"

# If there are global and local export file, load it first. 
# This affects subsequent behaviours of function effects.
safe_source "${ZSH_CONFIG}/exports.zsh"
safe_source "${ZSH_LOCAL_CONFIG}/exports.zsh"

# Auto start zellij
zellij_autostart

# Register tab name update for zellij
zellij_tab_name_update_by_git_repo
chpwd_functions+=(zellij_tab_name_update_by_git_repo)

# Enable colors
autoload -Uz colors && colors

# Allow comments as suffix to commands e.g. echo test # test
setopt interactive_comments

# History setup
setopt SHARE_HISTORY
HISTFILE="$ZSH_HISTORY_CACHE"
SAVEHIST=100000
HISTSIZE=99999
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS

# Enable zap
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

# Load zap plugins
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "zap-zsh/sudo"
plug "jeffreytse/zsh-vi-mode"

# Load add on settings and behaviours
safe_source "${ZSH_CONFIG}/functions/autocompletion.zsh"
safe_source "${ZSH_CONFIG}/functions/budget_z.zsh"
safe_source "${ZSH_CONFIG}/functions/notes.zsh"
safe_source "${ZSH_CONFIG}/functions/cmd.zsh"
safe_source "${ZSH_CONFIG}/functions/kubectl_cmd.zsh"
safe_source "${ZSH_CONFIG}/bindkeys.zsh"
safe_source "${ZSH_CONFIG}/aliases.zsh"

# Load local config files
if [[ -d "${ZSH_LOCAL_CONFIG}" ]]
then 
  for conf in "${ZSH_LOCAL_CONFIG}/"*.zsh(.N); do
    source "${conf}"
  done
  unset conf
fi

# Enable starship
# Check that the function `starship_zle-keymap-select()` is defined.
# xref: https://github.com/starship/starship/issues/3418
type starship_zle-keymap-select >/dev/null || \
  {
    eval "$(starship init zsh)"
  }

