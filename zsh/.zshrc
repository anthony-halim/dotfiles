export ZSH="${HOME}/.config/zsh"

# Load core utilities and custom functions
source "${ZSH}/functions.zsh"
# Load machine-specific settings and overrides if present
safe_source "${ZSH}/.zshrc.local"

#####################################
# Core setups
#####################################

# Enable colors
autoload -Uz colors && colors

# Allow comments as suffix to commands e.g. echo test # test
setopt interactive_comments

HISTFILE="${HOME}/.cache/.zsh_history"
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

# Aliases
alias src="source $HOME/.zshrc"
alias ll="ls -alrt"

path_append PATH "${HOME}/.local/bin"

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

# Async autocomplete to help with latency. Must be set before plugging the zsh-autosuggestions.
export ZSH_AUTOSUGGEST_USE_ASYNC=true 
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "jeffreytse/zsh-vi-mode"

plug "zap-zsh/sudo"
# Bind [Esc] [Esc] to sudo plugin
bindkey -M emacs '\e\e' sudo-command-line
bindkey -M vicmd '\e\e' sudo-command-line
bindkey -M viins '\e\e' sudo-command-line

#####################################
# WSL integration
#####################################

if command -v "explorer.exe" &>/dev/null; then
    alias open="explorer.exe"
fi

#####################################
# Pyenv integration
#####################################

if [[ -d "${HOME}/.pyenv" ]]; then
	export PYENV_ROOT="${HOME}/.pyenv"
	path_append PATH "$PYENV_ROOT/bin"
	eval "$(pyenv init -)"
fi

#####################################
# Go integration
#####################################

if [[ -x "/usr/local/go/bin/go" ]]; then
	path_append GOPATH "${HOME}/go"
	path_append PATH "/usr/local/go/bin" "${HOME}/go/bin"
fi

#####################################
# Rust integration
#####################################

if [[ -f "${HOME}/.cargo/env" ]]; then
	source "${HOME}/.cargo/env"
fi

#####################################
# Eza integration
#####################################

if command -v eza &>/dev/null; then
    alias ls="eza"
    alias ll="eza -alrg --icons auto"
fi

#####################################
# Kubectl integration
#####################################

if command -v kubectl &>/dev/null; then
    alias k="kubectl"
    alias kcc="kubectl config use-context"
    source <(kubectl completion zsh)

    path_append KUBECONFIG "${HOME}/.kube/config"
    # shellcheck disable=0-9999
    for file in "${HOME}/.kube/configs/"*.yaml(.N); do
      path_append KUBECONFIG "$file"
    done
fi

#####################################
# Bat ZSH integration
#####################################

if command -v batcat &>/dev/null; then
    alias cat="batcat --paging=never"
elif command -v bat &>/dev/null; then
    alias cat="bat --paging=never"
fi

#####################################
# Neovim ZSH integration
#####################################

if command -v nvim &>/dev/null; then
    export EDITOR="nvim"

    alias nv="nvim"
    alias vim="nvim"
fi

#####################################
# Lazygit ZSH integration
#####################################

if command -v lazygit &>/dev/null; then
    alias gg="lazygit"
fi

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

#####################################
# Zellij ZSH integration
#####################################

if command -v zellij &>/dev/null; then
    export ZELLIJ_CONFIG_DIR="${HOME}/.config/zellij"

    alias ze="zellij"
    alias zea="zellij attach -c"

    # Auto rename zellij tab if in Git repository
    zellij_tab_name_update_by_git_repo() {
        [[ -z "$ZELLIJ" ]] && return

        local tab_name
        if git rev-parse --is-inside-work-tree &>/dev/null; then
            tab_name=" $(basename "$(git rev-parse --show-toplevel)")"
        else
            tab_name="${PWD##*/}"
            [[ "$PWD" == "$HOME" ]] && tab_name="~"
        fi
        command nohup zellij action rename-tab "$tab_name" &>/dev/null
    }

    # Auto start/attach zellij
    zellij_autostart() {
        [[ -n "$ZELLIJ" ]] && return

        # Attach to existing session if possible, else start a new one.
        if [[ "$ZELLIJ_AUTO_START" == "true" ]]; then
            zellij attach -c || zellij
        fi
    }

    # Execute autostart and register renaming hook
    zellij_autostart
    zellij_tab_name_update_by_git_repo
    chpwd_functions+=(zellij_tab_name_update_by_git_repo)
fi
