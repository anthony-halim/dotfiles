path_append PATH "${HOME}/.local/bin"

# Pyenv
[[ -d "${HOME}/.pyenv" ]] && {
	export PYENV_ROOT="${HOME}/.pyenv"
	path_append PATH "$PYENV_ROOT/bin"
	eval "$(pyenv init -)"
}

# Golang
[[ -x "/usr/local/go/bin/go" ]] && {
	path_append GOPATH "${HOME}/go"
	path_append PATH "/usr/local/go/bin" "${HOME}/go/bin"
}

# Rust
[[ -f "${HOME}/.cargo/env" ]] && {
	source "${HOME}/.cargo/env"
}
