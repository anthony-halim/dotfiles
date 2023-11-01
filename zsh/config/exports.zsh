export PATH="${HOME}/.local/bin:$PATH"
export EDITOR="nvim"

# Zellij
export ZELLIJ_CONFIG_DIR="${HOME}/.config/zellij"

# Pyenv 
[[ -d "${HOME}/.pyenv" ]] && {
    export PYENV_ROOT="${HOME}/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval  "$(pyenv init -)"
}

# Golang 
[[ -x "/usr/local/go/bin/go" ]] && {
    command -v go >/dev/null || export PATH="/usr/local/go/bin:$PATH"
}

# Bob / Neovim
[[ -d "${HOME}/.local/share/bob/nvim-bin" ]] && {
    command -v nvim >/dev/null || export PATH="${HOME}/.local/share/bob/nvim-bin:$PATH"
}

# Fzf
[[ -f "${HOME}/.fzf.zsh" ]] && {
    source "${HOME}/.fzf.zsh"
}

# Sword
[[ -d "${HOME}/.sword" ]] && {
    export SWORD_PATH="${HOME}/.sword"
}

