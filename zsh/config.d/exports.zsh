export PATH="$HOME/.local/bin:$PATH"
export EDITOR="vim"

# Pyenv 
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval  "$(pyenv init -)"
