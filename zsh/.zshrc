# Set directories
export ZSH="${HOME}/.config/zsh"
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

HISTFILE="$ZSH_HISTORY_CACHE"
SAVEHIST=100000
HISTSIZE=99999
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt SHARE_HISTORY             # Share history between all sessions.

#####################################
# Zap (ZSH plugin manager)
#####################################

ZAP_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
if [[ ! -f "$ZAP_PATH" ]]; then
    echo "Error: Zap plugin manager is not installed."
    echo "Please run './setup.sh' to set up all dependencies."
    return 1 
fi
source "$ZAP_PATH"

plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "jeffreytse/zsh-vi-mode"

plug "zap-zsh/sudo"
# Bind [Esc] [Esc] to sudo plugin
bindkey -M emacs '\e\e' sudo-command-line
bindkey -M vicmd '\e\e' sudo-command-line
bindkey -M viins '\e\e' sudo-command-line

#####################################
# FZF ZSH integration
#####################################

if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
      --color=bg+:#232634,pointer:#ef9f76
      --border="rounded" --border-label-pos="0"
      --padding="1" --margin="1" --prompt="  " --marker=""
      --pointer="" --info="right"'

    plug "Aloxaf/fzf-tab"
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'   # Case-insensitive completion
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"  # Matching terminal colour
    zstyle ':fzf-tab:*' switch-group '<' '>'                 # Use <, >, to jump between groups
fi

#####################################
# Starship ZSH integration
#####################################

if command -v starship &>/dev/null; then
    # Check that the function `starship_zle-keymap-select()` is defined.
    # xref: https://github.com/starship/starship/issues/3418
    if [[ "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select" || \
          "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select-wrapped" ]]; then
        zle -N zle-keymap-select "";
    fi
    eval "$(starship init zsh)"
fi

# Load add on settings and behaviours
safe_source "${ZSH_CONFIG}/functions/autocompletion.zsh"
safe_source "${ZSH_CONFIG}/functions/budget_z.zsh"
safe_source "${ZSH_CONFIG}/functions/cmd.zsh"
safe_source "${ZSH_CONFIG}/aliases.zsh"

# Load local config files
if [[ -d "${ZSH_LOCAL_CONFIG}" ]]
then 
  for conf in "${ZSH_LOCAL_CONFIG}/"*.zsh(.N); do
    source "${conf}"
  done
  unset conf
fi

