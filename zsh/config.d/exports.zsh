# Include golang path
export PATH="/usr/local/go/bin:$HOME/.local/bin:$PATH"
export EDITOR="vim"

# Pyenv 
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval  "$(pyenv init -)"

