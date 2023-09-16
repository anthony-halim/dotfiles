# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="${HOME}/.config/zsh"
ZSH_CUSTOM="${ZSH}/custom"
ZSH_PLUGIN="${ZSH}/plugin"
ZSH_CONFIG="${ZSH}/config"
ZSH_LOCAL_CONFIG="${ZSH}/local_config"

# Enable colors
autoload -Uz colors && colors

# Allow comments as suffix to commands e.g. echo test # test
setopt interactive_comments

# Auto completion with tab
autoload -Uz compinit bashcompinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
bashcompinit
# Enable auto completion for terraform if exist
[[ ! -x /usr/bin/terraform ]] || complete -o nospace -C /usr/bin/terraform terraform
# Enable auto completion for kubectl if exist
[[ ! -x /usr/bin/kubectl ]] || source <(kubectl completion zsh) 
# Include hidden files.
_comp_options+=(globdots)

# History setup
setopt SHARE_HISTORY
HISTFILE=$HOME/.zsh_history
SAVEHIST=10000
HISTSIZE=9999
setopt HIST_EXPIRE_DUPS_FIRST

# Load functions
[[ ! -e "${ZSH_CONFIG}/omz_functions.zsh" ]] || source "${ZSH_CONFIG}/omz_functions.zsh"
[[ ! -e "${ZSH_CONFIG}/functions.zsh" ]] || source "${ZSH_CONFIG}/functions.zsh"

# NOTE: Exports activates necessary environments (which is dependency for some tools); source first.
safe_source "${ZSH_CONFIG}/exports.zsh"
safe_source "${ZSH_CONFIG}/aliases.zsh"

# Source theme 
safe_source "${ZSH_CUSTOM}/themes/powerlevel10k/powerlevel10k.zsh-theme" 

# Load plugins
zsh_load_local_plugin "zsh-autosuggestions" "zsh-autosuggestions.zsh"
zsh_load_local_plugin "zsh-syntax-highlighting" "zsh-syntax-highlighting.zsh"
zsh_load_local_plugin "zsh-history-substring-search" "zsh-history-substring-search.zsh"
zsh_load_local_plugin "sudo" "sudo.plugin.zsh"
zsh_load_local_plugin "web-search" "web-search.plugin.zsh"

# Bindkeys includes plugin keymaps, so must be done after plugin load
safe_source "${ZSH_CONFIG}/bindkeys.zsh"

# Load local config files
if [[ -d "${ZSH_LOCAL_CONFIG}" ]]
then 
  for conf in "${ZSH_LOCAL_CONFIG}/"*.zsh(.N); do
    source "${conf}"
  done
  unset conf
fi

# Settle tab title
DISABLE_AUTO_TITLE="true"
precmd () {
  print -Pn "\e]0;%~\a"
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# NOTE: We leave p10k config in default location to allow p10k to modify it normally
[[ ! -f "${HOME}/.p10k.zsh" ]] || source "${HOME}/.p10k.zsh"

