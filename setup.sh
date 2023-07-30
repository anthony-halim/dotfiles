#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
	cat <<EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(
		basename "${BASH_SOURCE[0]}"
	) [-h] [-v] [--disable_pwless_sudo] [--py_version python_semver] [--neovim_tag neovim_semver] -u username

Setup dependencies and setup local configuration.

Available options:

-u, --user                [Optional] Execute and install under this user. Defaults to the script executor. 
                                     If script is executed under sudo, we will check $SUDO_USER.
--disable_pwless_sudo     [FLAG] Skip configuring current user to have passwordless sudo access.
--neovim_tag              [Optional] [semver, x.x.x] Indicate NeoVim tag to be installed. Defaults to 0.9.1.
-h, --help                Print this help and exit
-v, --verbose             [FLAG] Print script debug info
EOF
	exit
}

cleanup() {
	trap - SIGINT SIGTERM ERR EXIT
	# script cleanup here
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

parse_params() {
	# default values of variables set from params
	USER_EXECUTOR=$(whoami)
	NEOVIM_TAG="0.9.1"
	IS_SKIP_SUDO=0

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		-u | --user)
			USER_EXECUTOR="${2-}"
			shift
			;;
		--no-color) NO_COLOR=1 ;;
		--disable_pwless_sudo) IS_SKIP_SUDO=1 ;;
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

	# Attempt to overwrite with $SUDO_USER if executor is root
	if [[ "${USER_EXECUTOR}" == root ]]; then
		USER_EXECUTOR="${SUDO_USER}"
		HOME=$(eval echo "~${SUDO_USER}")
	fi
	return 0
}

confirm() {
	while true; do
		read -p "  Do you want to proceed? [Y]es/[N]o) " yn
		case $yn in
		[Yy]*) return 0 ;;
		[Nn]*) return 1 ;;
		*) msg "  Please answer [Y]es or [N]o." ;;
		esac
	done
}

safe_symlink() {
	local real_file=$1
	local target=$2

	# Back up if its a directory or file
}

setup_pwless_sudo() {
	local sudoers_dir
	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		sudoers_dir="/private/etc/sudoers.d/"
	elif [[ "${OSTYPE}" =~ ^linux ]]; then
		sudoers_dir="/etc/sudoers.d/"
	fi

	sudoers_file="${sudoers_dir}/${USER_EXECUTOR}"
	touch "${sudoers_file}"
	echo "${USER_EXECUTOR} ALL=(ALL) NOPASSWD:ALL" >"${sudoers_file}"
	chown root:root "$sudoers_file"
	chmod 440 "$sudoers_file"

	msg_info "Success: configured passwordless sudo!"
}

setup_dependencies() {
	dependencies=("fzf" "ripgrep" "fd")
	for dependency in "${dependencies[@]}"; do
		if [[ "${OSTYPE}" =~ ^darwin ]]; then
			sudo brew install "${dependency}"
		elif [[ "${OSTYPE}" =~ ^linux ]]; then
			if [[ "${dependency}" == "fd" ]]; then dependency="fd-find"; fi
			sudo apt install -y "${dependency}"
		fi
	done

	msg_info "Success: dependencies installed!"
}

setup_lazygit() {
	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		sudo brew install lazygit
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
	[[ ! -d "${HOME}"/.pyenv ]] || rm -rf "${HOME}"/.pyenv

	git clone https://github.com/pyenv/pyenv.git "${HOME}"/.pyenv
	pyenv_bin="${HOME}/.pyenv/bin/pyenv"

	eval "$("${pyenv_bin}" init -)"

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
	sudo chsh --shell $(which zsh) "${USER_EXECUTOR}"

	msg_info "Success: ZSH installed!"
}

setup_omz() {
	git clone https://github.com/ohmyzsh/ohmyzsh.git "${HOME}"/.oh-my-zsh
	msg_info "Success: OMZ installed"
}

setup_omz_p10k() {
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
	msg_info "Success: p10k installed"
}

parse_params "$@"
setup_colors

msg_info "Parameters:"
msg_info "- user: ${USER_EXECUTOR}"
msg_info "- neovim_tag: ${NEOVIM_TAG}"
msg_info "- disable_pwless_sudo: ${IS_SKIP_SUDO}"

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
	msg "Script is executed as ${USER_EXECUTOR}. Subsequent installation and configuration will be done for ${USER_EXECUTOR} user."
	confirm || msg_warn "Script execution has been aborted!" && exit 1
fi

# Configure sudo
separator
if [[ "${IS_SKIP_SUDO}" -ne 1 ]] && [[ "${USER_EXECUTOR}" != "root" ]] && [[ -z "$(groups $USER_EXECUTOR | grep sudo)" ]]; then
	msg_info "Configuring passwordless sudo for user: ${USER_EXECUTOR}"
	confirm && setup_pwless_sudo
else
	msg_info "User: ${USER_EXECUTOR} has passwordless sudo, skipping..."
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
# NOTE: We are not able to check command pyenv, as sudo executed script will check the pyenv command under root user
separator
if [[ ! -e "${HOME}"/.pyenv/bin/pyenv ]]; then
	msg_info "Installing pyenv"
	confirm && setup_pyenv
else
	msg_info "pyenv: installed, skipping..."
fi

# TODO: Install rust
# TODO: Install golang

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
	confirm && setup_omz
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
