export PATH="${HOME}/.local/bin:$PATH"
export EDITOR="nvim"

# Zellij
export ZELLIJ_CONFIG_DIR="${HOME}/.config/zellij"

# Fzf
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=bg+:#232634,pointer:#ef9f76
  --border="rounded" --border-label-pos="0"
  --padding="1" --margin="1" --prompt="  " --marker=""
  --pointer="" --info="right"'

# Pyenv
[[ -d "${HOME}/.pyenv" ]] && {
	export PYENV_ROOT="${HOME}/.pyenv"
	command -v pyenv >/dev/null || export PATH="$PATH:$PYENV_ROOT/bin"
	eval "$(pyenv init -)"
}

# Golang
[[ -x "/usr/local/go/bin/go" ]] && {
	export GOPATH="${HOME}/go"
	command -v go >/dev/null || export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
}

# Rust
[[ -f "${HOME}/.cargo/env" ]] && {
	source "${HOME}/.cargo/env"
}

# Sword
[[ -d "${HOME}/.sword" ]] && {
	export SWORD_PATH="${HOME}/.sword"
}
