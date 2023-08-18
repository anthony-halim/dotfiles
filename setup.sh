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
	) [-h] [-v] [--git_user git_user] [--git_user_email git_user_email] [--git_user_local_file path_to_file] [--golang_tag golang_semver] [--golang_sys system_type] [--neovim_tag neovim_semver]

Setup dependencies and setup local configuration for the user.

IMPORTANT: Not to be executed as sudo. These configurations are meant for user-level configuration.

Available options:

--git_user                [Optional] [string]        Indicate git user. If empty, will be prompted later.
--git_user_email          [Optional] [string]        Indicate git user email. If empty, will be prompted later.
--git_user_local_file     [Optional] [string]        Configure git user and git email to a local file instead of the user's global .gitconfig. 
                                                     If empty, will default to global .gitconfig. 
                                                     Suitable for users who uses multiple gitconfigs.

--golang_tag              [Optional] [semver, x.x.x] Indicate Golang version to be installed. Defaults to 1.21.0.
--golang_sys              [Optional] [string]        Indicate system for Golang installation. 
                                                     For Linux based, this defaults to linux-amd64. 
                                                     For Darwin based, this defaults to darwin-amd64. 

--neovim_tag              [Optional] [semver, x.x.x] Indicate Neovim tag to be installed. Defaults to 0.9.1.

-h, --help                                           Print this help and exit
-v, --verbose             [FLAG]                     Print script debug info
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
	printf %"$(tput cols)"s | tr " " "─"
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
	GIT_USER=""
	GIT_USER_EMAIL=""
	GIT_USER_LOCAL_FILE=""
	NEOVIM_TAG="0.9.1"
	GOLANG_TAG="1.21.0"
	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		GOLANG_SYS="darwin-amd64"
	elif [[ "${OSTYPE}" =~ ^linux ]]; then
		GOLANG_SYS="linux-amd64"
	fi

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		--git_user)
			GIT_USER="${2-}"
			shift
			;;
		--git_user_email)
			GIT_USER_EMAIL="${2-}"
			shift
			;;
		--git_user_local_file)
			GIT_USER_LOCAL_FILE="${2-}"
			shift
			;;
		--golang_tag)
			GOLANG_TAG="${2-}"
			shift
			;;
		--golang_sys)
			GOLANG_SYS="${2-}"
			shift
			;;
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

	msg_info "  Creating ${target} -> ${real_file}"

	if [[ -L "${target}" && $(readlink -n "${target}") == "${real_file}" ]]; then
		msg_info "    -> Symlink already exist."
		return 0
	fi

	if [[ -L "${target}" ]]; then
		# Create backup symlink
		msg_warn "    ! ${target} is another symlink. We will create a symlink ${target}.bak to original target."
		confirm || {
			msg_warn "    ! Skipping..."
			return 0
		}
		ln -s "${target}.bak" "$(readlink -n "${target}")" && rm "${target}"

	elif [[ -f "${target}" || -d "${target}" ]]; then
		# Back up if its a directory or file
		msg_warn "  ! ${target} exists. We will first backup to ${target}.bak"
		confirm || {
			msg_warn "    ! Skipping..."
			return 0
		}
		mv "${target}" "${target}.bak"
	fi

	ln -s "${real_file}" "${target}"
	msg_info "    -> Symlink created!"
}

setup_dependencies() {
	dependencies=("wget" "fzf" "unzip" "ripgrep" "fd" "bat" "git" "ipcalc")
	for dependency in "${dependencies[@]}"; do
		msg_info "  -> Installing '$dependency'"
		if [[ "${OSTYPE}" =~ ^darwin ]]; then
			brew install "${dependency}"
		elif [[ "${OSTYPE}" =~ ^linux ]]; then
			if [[ "${dependency}" == "fd" ]]; then dependency="fd-find"; fi
			sudo apt install -y "${dependency}"
		fi
	done
}

setup_exa() {
	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		brew install exa
	elif [[ "${OSTYPE}" =~ ^linux ]]; then
		EXA_VERSION=$(curl -s "https://api.github.com/repos/ogham/exa/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
		curl -Lo exa.zip "https://github.com/ogham/exa/releases/latest/download/exa-linux-x86_64-v${EXA_VERSION}.zip"
		sudo unzip -q exa.zip bin/exa -d /usr/local

		# Clean up
		[[ ! -e "exa.zip" ]] || rm exa.zip
	fi
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
}

setup_pyenv() {
	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		brew install pyenv
	elif [[ "${OSTYPE}" =~ ^linux ]]; then
		git clone https://github.com/pyenv/pyenv.git "${HOME}"/.pyenv
	fi
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
}

setup_zsh() {
	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		sudo brew install zsh
	elif [[ "${OSTYPE}" =~ ^linux ]]; then
		sudo apt install -y zsh
	fi

	msg_info "  -> Setting zsh as default terminal"
	sudo chsh --shell "$(which zsh)" "${USER_EXECUTOR}"
}

setup_omz() {
	git clone https://github.com/ohmyzsh/ohmyzsh.git "${HOME}"/.oh-my-zsh
}

setup_omz_p10k() {
	msg "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
}

setup_rust() {
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

setup_go() {
	local golang_pkg="go${GOLANG_TAG}.${GOLANG_SYS}.tar.gz"
	wget "https://go.dev/dl/${golang_pkg}"

	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		msg_warn "  ! For Darwin based, please manually open the dowloaded package and follow the prompts: ${golang_pkg}"
		return 0
	fi

	if [[ -d "/usr/local/go" ]]; then
		msg_warn "  ! Existing go directory is present at /usr/local/go. We need to remove the directory completely to proceed."
		confirm || {
			msg_warn "  ! Skipping..."
			return 0
		}
		rm -rf /usr/local/go
	fi

	sudo tar -C /usr/local/ -xzf "${golang_pkg}"

	# Clean up
	[[ ! -e "${golang_pkg}" ]] || rm -rf "${golang_pkg}"
}

setup_git() {
	# Global configs
	declare -A git_global_configs

	git_global_configs["alias.lg"]="log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
	git_global_configs["core.editor"]="vim"
	git_global_configs["pull.rebase"]="true"
	git_global_configs["url.\"ssh://git@github.com/\".insteadOf"]="https//github.com/"

	for git_conf in "${!git_global_configs[@]}"; do
		local git_conf_cmd="${git_global_configs[$git_conf]}"

		msg_info "  -> Setting global conf $git_conf = $git_conf_cmd"
		local git_conf_cmd_exist=$(git config --get "$git_conf") || 0

		if [[ -n "$git_conf_cmd_exist" ]]; then
			if [[ "$git_conf_cmd_exist" == "$git_conf_cmd" ]]; then
				msg_info "    -> Config already exist"
			else
				msg_warn "    ! Config is already used. To overwrite it, you can execute:"
				msg_warn "    ! git config --global $git_conf $git_conf_cmd"
			fi
		else
			confirm || {
				msg_warn "    ! Skipping..."
				continue
			}
			git config --global "$git_conf" "$git_conf_cmd"
		fi
	done

	# User identity

	local git_location_flag="--global"
	if [[ -n "$GIT_USER_LOCAL_FILE" ]]; then
		git_location_flag="--file $GIT_USER_LOCAL_FILE"
		touch "$GIT_USER_LOCAL_FILE"
	fi
	msg_info "  Git user.name and user.email location flag is set to '$git_location_flag'"

	if [[ -z "$GIT_USER" ]]; then
		read -r -p "    ? Please input your git user.name: " git_username_input
		GIT_USER="$git_username_input"
	fi
	if [[ -z "$GIT_USER_EMAIL" ]]; then
		read -r -p "    ? Please input your git user.email: " git_user_email_input
		GIT_USER_EMAIL="$git_user_email_input"
	fi

	msg_warn "    -> git user.name will be set to '$GIT_USER'"
	confirm && git config "$git_location_flag user.name $GIT_USER" && msg_info "    -> user.name is set!"
	msg_warn "    -> git user.email will be set to '$GIT_USER_EMAIL'"
	confirm && git config "$git_location_flag user.email $GIT_USER_EMAIL" && msg_info "    -> user.email is set!"
}

parse_params "$@"
setup_colors

msg_info "Script Parameters:"
msg_info "  -> user: ${USER_EXECUTOR}"
[[ -n "$GIT_USER" ]] && msg_info "  -> git_user: ${GIT_USER}"
[[ -n "$GIT_USER_EMAIL" ]] && msg_info "  -> git_user_email: ${GIT_USER_EMAIL}"
[[ -n "$GIT_USER_LOCAL_FILE" ]] && msg_info "  -> git_user_local_file: ${GIT_USER_LOCAL_FILE}"
msg_info "  -> golang_tag: ${GOLANG_TAG}"
msg_info "  -> golang_sys: ${GOLANG_SYS}"
msg_info "  -> neovim_tag: ${NEOVIM_TAG}"

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
msg_info "deps: installing dependencies"
confirm && setup_dependencies && msg_info "deps: success!"

# Git setup
separator
msg_info "git_conf: setting up Git configurations"
confirm && setup_git && msg_info "git_conf: success!"

# Exa installation
separator
if [[ ! $(command -v exa) ]]; then
	msg_info "exa: installing exa (better ls)"
	confirm && setup_exa && msg_info "exa: success!"
else
	msg_info "exa: installed, skipping..."
fi

# Lazygit installation
separator
if [[ ! $(command -v lazygit) ]]; then
	msg_info "lazygit: installing lazygit (simple terminal UI for git commands)"
	confirm && setup_lazygit && msg_info "lazygit: success!"
else
	msg_info "lazygit: installed, skipping..."
fi

# Pyenv installation
separator
if [[ ! $(command -v pyenv) ]]; then
	msg_info "pyenv: installing pyenv (Python version manager)"
	confirm && setup_pyenv && msg_info "pyenv: success!"
else
	msg_info "pyenv: installed, skipping..."
fi

# Golang installation
separator
if [[ ! $(command -v go) ]]; then
	msg_info "Golang: installing Golang (programming language)"
	confirm && setup_go && msg_info "Golang: success!"
else
	msg_info "Golang: installed, skipping..."
fi

# Rust installation
separator
if [[ ! $(command -v rustup) ]]; then
	msg_info "Rust: installing Rust (programming language) with rustup"
	confirm && setup_rust && msg_info "Ruat: success!"
else
	msg_info "Rust: installed, skipping..."
fi

# NeoVim installation
separator
if [[ ! $(command -v nvim) ]]; then
	msg_info "Neovim: installing Neovim version ${NEOVIM_TAG}"
	confirm && setup_neovim && msg_info "Neovim: success!"
else
	msg_info "Neovim: installed, skipping..."
fi

# ZSH installation and setup
separator
if [[ ! $(command -v zsh) ]]; then
	msg_info "zsh: installing Z shell and setting it as default terminal"
	confirm && setup_zsh && msg_info "zsh: success!"
else
	msg_info "zsh: installed, skipping..."
fi

# OMZ installation
separator
if [[ $(command -v zsh) ]] && [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
	msg_info "omz: installing omz (Oh My Zsh, zsh package manager)"
	confirm && setup_omz && msg_info "omz: success!"
else
	msg_info "omz: installed, skipping..."
fi

# p10k installation
separator
if [[ $(command -v zsh) ]] && [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
	msg "p10k: installing p10k (theme for zsh)"
	confirm && setup_omz_p10k && msg_info "p10k: success!"
else
	msg_info "p10k: installed, skipping..."
fi

# Create directory to hold local configs
separator
mkdir -p "${HOME}/.local_configs"
msg_info "local_configs: created directory for local configs at ${HOME}/.local_configs. You can use it to place uncommited configurations."

# Create symbolic link configuration
# NOTE: The path is super dependent on the repository directory structure.
separator
msg_info "symlink: setting up soft links to repository configuration"
safe_symlink "${SCRIPT_DIR}/zsh" "${HOME}/.config/zsh"
safe_symlink "${SCRIPT_DIR}/zsh/.zshrc" "${HOME}/.zshrc"
safe_symlink "${SCRIPT_DIR}/zsh/.p10k.zsh" "${HOME}/.p10k.zsh"
safe_symlink "${SCRIPT_DIR}/wezterm/wezterm.lua" "${HOME}/.wezterm.lua"
msg_info "symlink: success!"
