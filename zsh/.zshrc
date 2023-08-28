# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

safe_source() {
  [[ ! -e "$1" ]] || source "$1"
}

export ZSH="${HOME}/.zsh"
export ZSH_CORE="${ZSH}/core"
export ZSH_CUSTOM="${ZSH}/custom"
export ZSH_PLUGIN="${ZSH}/plugins"
export ZSH_CONFIG="${ZSH}/config.d"
export ZSH_LOCAL_CONFIG="${ZSH}/.local_config.d"

# Load core functionalities
safe_source "${ZSH_CORE}/zsh-autosuggestions/zsh-autosuggestions.zsh" 
safe_source "${ZSH_CORE}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
safe_source "${ZSH_CORE}/zsh-history-substring-search/zsh-history-substring-search.zsh"

# Source theme 
safe_source "${ZSH_CUSTOM}/themes/powerlevel10k/powerlevel10k.zsh-theme" 

# Load plugins
if [[ -d "${ZSH_PLUGIN}" ]]
then 
  for conf in "${ZSH_PLUGIN}/"*.zsh(.N); do
    source "${conf}"
  done
  unset conf
fi

# Load config files
if [[ -d "${ZSH_CONFIG}" ]]
then 
  for conf in "${ZSH_CONFIG}/"*.zsh(.N); do
    source "${conf}"
  done
  unset conf
fi

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
