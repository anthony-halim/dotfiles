export PATH="${HOME}/.local/bin:$PATH"
export EDITOR="nvim"

# Rust
# NOTE We source this first, as many tools have cargo as dependency. Primarily those installed via cargo.
[[ -e "${HOME}/.cargo/env" ]] && {
  source "${HOME}/.cargo/env" 
}

# Zellij
export ZELLIJ_CONFIG_DIR="${HOME}/.config/zellij"
export ZELLIJ_AUTO_ATTACH=true

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

