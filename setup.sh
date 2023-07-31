#!/usr/bin/env bash

set -Eeuo pipefail
trap catch_err ERR
trap cleanup SIGINT SIGTERM EXIT

USER_EXECUTOR=$(whoami)
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
	cat <<EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(
		basename "${BASH_SOURCE[0]}"
	) [-h] [-v] [--py_version python_semver] [--neovim_tag neovim_semver]

Setup dependencies and setup local configuration for the user.

IMPORTANT: Not to be executed as sudo. These configurations are meant for user-level configuration.

Available options:

--neovim_tag              [Optional] [semver, x.x.x] Indicate NeoVim tag to be installed. Defaults to 0.9.1.
-h, --help                Print this help and exit
-v, --verbose             [FLAG] Print script debug info
EOF
	exit
}

cleanup() {
	trap - SIGINT SIGTERM EXIT
	# script cleanup here
}

catch_err() {
	msg_err "$(caller): Execution failed at this line."
	cleanup
}

setup_colors() {
	if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
		NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
	else
		NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
	fi
}

separator() {
	msg "${CYAN}-------------------------------------${NOFORMAT}"
}

msg() {
	echo >&2 -e "${1-}"
}

msg_info() {
	msg "${GREEN}$1${NOFORMAT}"
}

msg_warn() {
	msg "${ORANGE}$1${NOFORMAT}"
}

msg_err() {
	msg "${RED}$1${NOFORMAT}"
}

die() {
	local msg=$1
	local code=${2-1} # default :exit status 1
	msg "$msg"
	exit "$code"
}

confirm() {
	while true; do
		read -r -p "  Do you want to proceed? [Y]es/[N]o) " yn
		case $yn in
		[Yy]*) return 0 ;;
		[Nn]*) return 1 ;;
		*) msg "  Please answer [Y]es or [N]o." ;;
		esac
	done
}

parse_params() {
	# default values of variables set from params
	NEOVIM_TAG="0.9.1"

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		--neovim_tag)
			NEOVIM_TAG="${2-}"
			shift
			;;
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")

	return 0
}

safe_symlink() {
	local real_file=$1
	local target=$2

	msg_info "Symlink: creating ${target} -> ${real_file}"

	if [[ -L "${target}" && $(readlink -n "${target}") == "${real_file}" ]]; then
		msg_warn "  Symlink: already exist. Skipping creation..."
		return 0
	fi

	if [[ -L "${target}" ]]; then
		# Create backup symlink
		msg_warn "  Symlink: ${target} is another symlink. We will create a symlink ${target}.bak to original target."
		confirm || {
			msg_warn "  Symlink: backup aborted. Skipping creation..."
			return 0
		}
		ln -s "${target}.bak" "$(readlink -n "${target}")" && rm "${target}"

	elif [[ -f "${target}" || -d "${target}" ]]; then
		# Back up if its a directory or file
		msg_warn "  Symlink: ${target} exists. We will backup to ${target}.bak"
		# If user does not want to backup, skip
		confirm || {
			msg_warn "  Symlink: backup aborted. Skipping creation..."
			return 0
		}
		mv "${target}" "${target}.bak"
	fi

	ln -s "${real_file}" "${target}"
	msg_info "  Symlink: created!"
}

setup_dependencies() {
	dependencies=("fzf" "ripgrep" "fd")
	for dependency in "${dependencies[@]}"; do
		if [[ "${OSTYPE}" =~ ^darwin ]]; then
			brew install "${dependency}"
		elif [[ "${OSTYPE}" =~ ^linux ]]; then
			if [[ "${dependency}" == "fd" ]]; then dependency="fd-find"; fi
			sudo apt install -y "${dependency}"
		fi
	done

	msg_info "Success: dependencies installed!"
}

setup_lazygit() {
	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		brew install lazygit
	elif [[ "${OSTYPE}" =~ ^linux ]]; then
		LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
		curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
		tar xf lazygit.tar.gz lazygit
		sudo install lazygit /usr/local/bin
	fi

	# Clean up
	[[ ! -e "lazygit.tar.gz" ]] || rm lazygit.tar.gz

	msg_info "Success: lazygit installed!"
}

setup_pyenv() {
	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		brew install pyenv
	elif [[ "${OSTYPE}" =~ ^linux ]]; then
		git clone https://github.com/pyenv/pyenv.git "${HOME}"/.pyenv
	fi

	msg_info "Success: installed pyenv!"
}

setup_neovim() {
	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		binary_release="nvim-macos"
	elif [[ "${OSTYPE}" =~ ^linux ]]; then
		binary_release="nvim-linux64"
	fi

	# Remove previous installation
	[[ ! -e "${binary_release}.tar.gz" ]] || rm -rf "${binary_release}.tar.gz"

	wget "https://github.com/neovim/neovim/releases/download/v${NEOVIM_TAG}/${binary_release}.tar.gz"

	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		# Avoid unknown developer warning
		xattr -c "./${binary_release}.tar.gz"
	fi

	tar xzvf "${binary_release}.tar.gz"
	mv "${binary_release}" /usr/share
	safe_symlink "/usr/share/${binary_release}/bin/nvim" /usr/bin/nvim

	# Clean up
	[[ ! -e "${binary_release}.tar.gz" ]] || rm -rf "${binary_release}.tar.gz"

	msg_info "Success: installed NeoVim!"
}

setup_zsh() {
	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		sudo brew install zsh
	elif [[ "${OSTYPE}" =~ ^linux ]]; then
		sudo apt install -y zsh
	fi

	msg_info "Setting ZSH as default terminal"
	sudo chsh --shell "$(which zsh)" "${USER_EXECUTOR}"

	msg_info "Success: ZSH installed!"
}

setup_omz() {
	git clone https://github.com/ohmyzsh/ohmyzsh.git "${HOME}"/.oh-my-zsh
	msg_info "Success: OMZ installed"
}

setup_omz_p10k() {
	msg "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
	msg_info "Success: p10k installed"
}

setup_rust() {
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	msg_info "Success: rust installed"
}

parse_params "$@"
setup_colors

msg_info "Parameters:"
msg_info "- user: ${USER_EXECUTOR}"
msg_info "- neovim_tag: ${NEOVIM_TAG}"

# Check OS
if [[ ! "${OSTYPE}" =~ ^linux ]] && [[ ! "${OSTYPE}" =~ ^darwin ]]; then
	msg_err "Unsupported OS: ${OSTYPE}"
	die
fi

# Detected that script is executed under root.
# This will cause subsequent installation and configuration to be done for root user.
# Prompt for confirmation.
if [[ "${USER_EXECUTOR}" == "root" ]]; then
	separator
	msg_err "Script is executed as ${USER_EXECUTOR}. Installation and configuration is not meant for system-level."
	exit 1
fi

# Dependencies installation
separator
msg_info "Installing dependencies"
confirm && setup_dependencies

# Lazygit installation
separator
if [[ ! $(command -v lazygit) ]]; then
	msg_info "Installing lazygit"
	confirm && setup_lazygit
else
	msg_info "lazygit: installed, skipping..."
fi

# Pyenv installation
separator
if [[ ! $(command -v pyenv) ]]; then
	msg_info "Installing pyenv"
	confirm && setup_pyenv
else
	msg_info "pyenv: installed, skipping..."
fi

# Rust installation
separator
if [[ ! $(command -v rustup) ]]; then
	msg_info "Installing rust (using rustup)"
	confirm && setup_rust
else
	msg_info "rust: installed, skipping..."
fi

# NeoVim installation
separator
if [[ ! $(command -v nvim) ]]; then
	msg_info "Installing NeoVim: ${NEOVIM_TAG}"
	confirm && setup_neovim
else
	msg_info "NeoVim: installed, skipping..."
fi

# ZSH installation and setup
separator
if [[ ! $(command -v zsh) ]]; then
	msg_info "Installing ZSH and setting it as default terminal"
	confirm && setup_zsh
else
	msg_info "ZSH: installed, skipping..."
fi

# OMZ installation
separator
if [[ $(command -v zsh) ]] && [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
	msg_info "Installing OMZ for ZSH"
	confirm && setup_omz
else
	msg_info "OMZ: installed, skipping..."
fi

# p10k installation
separator
if [[ $(command -v zsh) ]] && [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
	msg "Installing p10k theme for ZSH"
	confirm && setup_omz_p10k
else
	msg_info "p10k theme for ZSH: installed, skipping..."
fi

# Create symbolic link configuration
separator
msg_info "Setting up soft links to repository configuration"

# NOTE: The path is super dependent on the repository directory structure.
safe_symlink "${SCRIPT_DIR}/gitconfig/.gitconfig" "${HOME}/.gitconfig"
safe_symlink "${SCRIPT_DIR}/gitconfig/.gitconfig-personal" "${HOME}/.gitconfig-personal"
safe_symlink "${SCRIPT_DIR}/gitconfig/.gitconfig-work" "${HOME}/.gitconfig-work"
safe_symlink "${SCRIPT_DIR}/zsh" "${HOME}/.config/zsh"
safe_symlink "${SCRIPT_DIR}/zsh/.zshrc" "${HOME}/.zshrc"
safe_symlink "${SCRIPT_DIR}/zsh/.p10k.zsh" "${HOME}/.p10k.zsh"
safe_symlink "${SCRIPT_DIR}/wezterm/wezterm.lua" "${HOME}/.wezterm.lua"
