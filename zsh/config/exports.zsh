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

# Rust
[[ -f "${HOME}/.cargo/env" ]] && {
    source "${HOME}/.cargo/env"
}

# Fzf
[[ -f "${HOME}/.fzf.zsh" ]] && {
    source "${HOME}/.fzf.zsh"
}

# Sword
[[ -d "${HOME}/.sword" ]] && {
    export SWORD_PATH="${HOME}/.sword"
}

