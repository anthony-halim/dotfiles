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
	) [-h] [-v] [--git_user git_user] [--git_user_email git_user_email] [--git_user_local_file path_to_file] 
                [--golang_tag golang_semver] [--golang_sys system_type]
                [--neovim_tag neovim_semver]

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
	msg "─────────────────────────────────────────────────────────────────"
}

msg() {
	echo >&2 -e "${1-}"
}

msg_info() {
	msg "${YELLOW}$1${NOFORMAT}"
}

msg_warn() {
	msg "${ORANGE}$1${NOFORMAT}"
}

msg_err() {
	msg "${RED}$1${NOFORMAT}"
}

msg_success() {
	msg "${GREEN}$1${NOFORMAT}"
}

die() {
	local msg=$1
	local code=${2-1} # default :exit status 1
	msg "$msg"
	exit "$code"
}

confirm() {
	while true; do
		read -r -p "    Do you want to proceed? [Y]es/[N]o) " yn
		case $yn in
		[Yy]*) return 0 ;;
		[Nn]*) return 1 ;;
		*) msg "    Please answer [Y]es or [N]o." ;;
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

	# Expand path
	GIT_USER_LOCAL_FILE="${GIT_USER_LOCAL_FILE/#\~/$HOME}"

	return 0
}

safe_symlink() {
	local real_file=$1
	local target=$2

	msg "  Creating ${target} -> ${real_file}"

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
	msg_success "    -> Symlink created!"
}

setup_dependencies() {
	local dependencies=("wget" "fzf" "unzip" "ripgrep" "fd" "bat" "git" "ipcalc")
	for dependency in "${dependencies[@]}"; do
		msg_info "  Installing '$dependency'"
		if [[ "${OSTYPE}" =~ ^darwin ]]; then
			brew install "${dependency}"
		elif [[ "${OSTYPE}" =~ ^linux ]]; then
			if [[ "${dependency}" == "fd" ]]; then dependency="fd-find"; fi
			sudo apt install -y "${dependency}"
		fi
	done
}

setup_exa() {
	if [[ $(command -v exa) ]]; then
		msg_warn " ! already installed, skipping..."
		return 0
	fi

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
	if [[ $(command -v lazygit) ]]; then
		msg_warn "  ! already installed, skipping..."
		return 0
	fi

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
	if [[ $(command -v pyenv) ]]; then
		msg_warn "  ! already installed, skipping..."
		return 0
	fi

	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		brew install pyenv
	elif [[ "${OSTYPE}" =~ ^linux ]]; then
		git clone https://github.com/pyenv/pyenv.git "${HOME}"/.pyenv
	fi
}

setup_neovim() {
	safe_clean_cache() {
		local timestamp=$(date '+%s')
		local cache_locations=("${HOME}/.local/share/nvim" "${HOME}/.local/state/nvim" "${HOME}/.cache/nvim")
		for cache_location in "${cache_locations[@]}"; do
			if [[ -e "${cache_location}" ]]; then
				msg_info "${cache_location} exists. We will back up to ${cache_location}.bak.${timestamp}"
				mv "${cache_location}" "${cache_location}.bak.${timestamp}"
			fi
		done
		return 0
	}

	if [[ $(command -v nvim) ]]; then
		local nvim_version=$(nvim --version | head -1 | grep -o '[0-9]\.[0-9]\.[0-9]')
		if [[ "$nvim_version" != "${NEOVIM_TAG}" ]]; then
			msg_warn "  ! detected Neovim of version ${nvim_version}. Please remove it if you wish to install version ${NEOVIM_TAG}."
			return 0
		else
			msg_warn "  ! already installed, skipping..."
			return 0
		fi

		msg "  Removing Neovim caches. Existing caches may interfere with subsequent package installations."
		confirm && safe_clean_cache
	fi

	local binary_release=""
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
	if [[ ! $(command -v zsh) ]]; then
		msg "  Installing zsh"
		if [[ "${OSTYPE}" =~ ^darwin ]]; then
			sudo brew install zsh
		elif [[ "${OSTYPE}" =~ ^linux ]]; then
			sudo apt install -y zsh
		fi
	fi

	local user_default_shell=$(finger "${USER_EXECUTOR}" | grep -o "Shell: .*" | cut -d" " -f2 | xargs basename)
	if [[ "$user_default_shell" != "zsh" ]]; then
		msg "  Setting zsh as default terminal"
		sudo chsh -s "$(which zsh)" "${USER_EXECUTOR}"
	fi
}

setup_rust() {
	if [[ $(command -v rustup) ]]; then
		msg_warn "  ! already installed, skipping..."
		return 0
	fi

	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

setup_go() {
	if [[ $(command -v go) ]]; then
		local go_version=$(go version | grep -oE '[0-9]\.[0-9]+\.[0-9]+')
		if [[ "$go_version" != "${GOLANG_TAG}" ]]; then
			msg_warn "  ! detected Golang of version ${go_version}. Removing existing installation."
			confirm || {
				msg_warn "  ! Skipping..."
				return 0
			}
			sudo rm -rf /usr/local/go
		else
			msg_warn "  ! already installed, skipping..."
			return 0
		fi
	fi

	local golang_pkg="go${GOLANG_TAG}.${GOLANG_SYS}.tar.gz"
	wget "https://go.dev/dl/${golang_pkg}"

	if [[ -d "/usr/local/go" ]]; then
		msg_warn "  ! Existing go directory is present at /usr/local/go. We need to remove the directory completely to proceed."
		confirm || {
			msg_warn "  ! Skipping..."
			return 0
		}
		sudo rm -rf /usr/local/go
	fi

	sudo tar -C /usr/local/ -xzf "${golang_pkg}"

	# Clean up
	[[ ! -e "${golang_pkg}" ]] || rm -rf "${golang_pkg}"
}

setup_git() {
	set_git_conf() {
		local git_location=$1
		local git_conf_name=$2
		local git_conf_cmd=$3

		msg "  Setting $git_location: $git_conf_name = $git_conf_cmd"

		local git_conf_existing_cmd=$(bash -c "git config $git_location --get $git_conf_name") || 0
		if [[ -n "$git_conf_existing_cmd" ]]; then
			if [[ "$git_conf_existing_cmd" == "$git_conf_cmd" ]]; then
				msg_info "    -> Config already exist"
			else
				msg_warn "    ! Config is already used. To overwrite it, you can execute:"
				msg_warn "    ! git config $git_location $git_conf_name $git_conf_cmd"
			fi
		else
			bash -c "git config $git_location $git_conf_name '$git_conf_cmd'"
			msg_success "    -> Config set!"
		fi
	}

	local git_location_flag="--global"

	# Global config

	set_git_conf "$git_location_flag" "include.path" "${HOME}/.gitconfig-base"

	# User identity

	if [[ -n "$GIT_USER_LOCAL_FILE" ]]; then
		msg "  Local user configuration to be set at ${GIT_USER_LOCAL_FILE}"
		git_location_flag="-f '$GIT_USER_LOCAL_FILE'"

		if [[ ! -e "$GIT_USER_LOCAL_FILE" ]]; then
			touch "$GIT_USER_LOCAL_FILE"
			msg_info "    -> Created local file at $GIT_USER_LOCAL_FILE"
		fi
	fi

	if [[ -z "$GIT_USER" ]]; then
		msg_warn "    ! git user.name is not supplied."
		read -r -p "    ? Please input your git user.name: " git_username_input
		GIT_USER="$git_username_input"
	fi
	if [[ -z "$GIT_USER_EMAIL" ]]; then
		msg_warn "    ! git user.email is not supplied."
		read -r -p "    ? Please input your git user.email: " git_user_email_input
		GIT_USER_EMAIL="$git_user_email_input"
	fi

	set_git_conf "$git_location_flag" "user.name" "$GIT_USER"
	set_git_conf "$git_location_flag" "user.email" "$GIT_USER_EMAIL"
}

setup_colors
parse_params "$@"

msg_info "Script Parameters:"
msg "  -> user: ${USER_EXECUTOR}"
[[ -n "$GIT_USER" ]] && msg "  -> git_user: ${GIT_USER}"
[[ -n "$GIT_USER_EMAIL" ]] && msg "  -> git_user_email: ${GIT_USER_EMAIL}"
[[ -n "$GIT_USER_LOCAL_FILE" ]] && msg "  -> git_user_local_file: ${GIT_USER_LOCAL_FILE}"
msg "  -> golang_tag: ${GOLANG_TAG}"
msg "  -> golang_sys: ${GOLANG_SYS}"
msg "  -> neovim_tag: ${NEOVIM_TAG}"

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
confirm && setup_dependencies && msg_success "deps: success!"

# Git setup
separator
msg_info "git_conf: setting up Git configurations"
confirm && setup_git && msg_success "git_conf: success!"

# Exa installation
separator
msg_info "exa: installing exa (better ls)"
confirm && setup_exa && msg_success "exa: success!"

# Lazygit installation
separator
msg_info "lazygit: installing lazygit (simple terminal UI for git commands)"
confirm && setup_lazygit && msg_success "lazygit: success!"

# Pyenv installation
separator
msg_info "pyenv: installing pyenv (Python version manager)"
confirm && setup_pyenv && msg_success "pyenv: success!"

# Golang installation
separator
msg_info "Golang: installing Golang (programming language)"
confirm && setup_go && msg_success "Golang: success!"

# Rust installation
separator
msg_info "Rust: installing Rust (programming language) with rustup"
confirm && setup_rust && msg_success "Rust: success!"

# Neovim installation
separator
msg_info "Neovim: installing Neovim version ${NEOVIM_TAG}"
confirm && setup_neovim && msg_success "Neovim: success!"

# ZSH installation
separator
msg_info "zsh: installing Z-Shell"
confirm && setup_zsh && msg_success "zsh: success!"

# Create directory to hold local configs
separator
mkdir -p "${HOME}/.config/zsh/local_config"
msg_info "local_configs: created directory for local configs at ${HOME}/.config/zsh/local_config. You can use it to place uncommited configurations."

# Create symbolic link configuration
separator
msg_info "symlink: setting up soft links to repository configuration"
safe_symlink "${SCRIPT_DIR}/gitconfig/.gitconfig-base" "${HOME}/.gitconfig-base"
safe_symlink "${SCRIPT_DIR}/zsh" "${HOME}/.config/zsh"
safe_symlink "${SCRIPT_DIR}/zsh/.zshrc" "${HOME}/.zshrc"
safe_symlink "${SCRIPT_DIR}/zsh/.p10k.zsh" "${HOME}/.p10k.zsh"
safe_symlink "${SCRIPT_DIR}/wezterm/wezterm.lua" "${HOME}/.wezterm.lua"
msg_success "symlink: success!"

# Report git information at the very end to make it clear to user
if [[ -n "$GIT_USER_LOCAL_FILE" ]]; then
	separator
	msg_info "You have set local git user configuration file. To include local git file, you can add the following to your global .gitconfig:"

	msg " "
	msg "# For global include"
	msg "[include]"
	msg "    path = $GIT_USER_LOCAL_FILE"
	msg " "
	msg "# Or, for conditional include"
	msg "[includeIf \"gitdir:/path/to/dir/\"] # Change this!"
	msg "    path = $GIT_USER_LOCAL_FILE"
	msg " "
fi
