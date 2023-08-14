export PATH="${HOME}/.local/bin:$PATH"
export EDITOR="vim"

# Pyenv 
if [[ -d "${HOME}/.pyenv" ]]; then
    export PYENV_ROOT="${HOME}/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval  "$(pyenv init -)"
fi

# Golang 
if [[ -x "/usr/local/go/bin/go" ]]; then
    command -v go >/dev/null || export PATH="/usr/local/go/bin:$PATH"
fi

# Rust
if [[ -e "${HOME}/.cargo/env" ]]; then
    source "${HOME}/.cargo/env" 
fi

# Fzf
if [[ -f "${HOME}/.fzf.zsh" ]]; then
    source "${HOME}/.fzf.zsh"
fi 

# Sword
if [[ -d "${HOME}/.sword" ]]; then
    export SWORD_PATH="${HOME}/.sword"
fi
