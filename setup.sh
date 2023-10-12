#!/usr/bin/env bash

set -Eeuo pipefail
trap catch_err ERR
trap cleanup SIGINT SIGTERM EXIT

# Constants
USER_EXECUTOR=$(whoami)
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
LOCAL_CONFIG_DIR="$HOME/.config/zsh/local_config"
GIT_USER=""
GIT_USER_EMAIL=""
GIT_USER_LOCAL_FILE=""
NEOVIM_TAG="latest"
GOLANG_TAG="1.21.0"
if [[ "${OSTYPE}" =~ ^darwin ]]; then
	GOLANG_SYS="darwin-amd64"
elif [[ "${OSTYPE}" =~ ^linux ]]; then
	GOLANG_SYS="linux-amd64"
fi

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

--golang_tag              [Optional] [semver, x.x.x] Indicate Golang version to be installed. Defaults to $GOLANG_TAG.
--golang_sys              [Optional] [string]        Indicate system for Golang installation. 
                                                     Based on your current OS: $OSTYPE, defaults to $GOLANG_SYS.

--neovim_tag              [Optional] [semver, x.x.x] Indicate Neovim tag to be installed. Defaults to $NEOVIM_TAG.

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
	msg_err "$msg"
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

parse_semver() {
	local input_semver="$1"
	local info_msg="$2"

	if [[ "$input_semver" =~ ^v ]]; then
		input_semver=$(echo "$input_semver" | cut --delimiter='v' --fields=2)
		msg "  Translated $info_msg: v$input_semver to $input_semver"
	fi
	echo "$input_semver"
}

parse_params() {
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

	# Auto-fix semver parameters
	NEOVIM_TAG=$(parse_semver "$NEOVIM_TAG" "neovim_tag")
	GOLANG_TAG=$(parse_semver "$GOLANG_TAG" "golang_tag")

	# Expand neovim version
	if [[ "$NEOVIM_TAG" == "latest" ]]; then
		msg "  neovim_tag is set to '$NEOVIM_TAG'. Fetching latest tag..."
		NEOVIM_TAG=$(
			git -c 'versionsort.suffix=-' \
				ls-remote --exit-code --refs --sort='version:refname' --tags https://github.com/neovim/neovim '*.*.*' |
				tail --lines=1 |
				cut --delimiter='/' --fields=3 | cut --delimiter='v' --fields=2
		)
		msg_success "  -> Translated neovim_tag to '$NEOVIM_TAG'."
	fi

	return 0
}

safe_symlink() {
	local real_file=$1
	local target=$2

	msg "  Creating ${target} -> ${real_file}"

	if [[ -L "${target}" && $(readlink -n "${target}") == "${real_file}" ]]; then
		msg_info "  -> Symlink already exist."
		return 0
	fi

	if [[ -L "${target}" ]]; then
		# Create backup symlink
		msg_warn "  ! ${target} is another symlink. We will create a symlink ${target}.bak to original target."
		confirm || {
			msg_warn " ! Skipping..."
			return 0
		}
		ln -s "$(readlink -n "${target}")" "${target}.bak" && rm "${target}"

	elif [[ -f "${target}" || -d "${target}" ]]; then
		# Back up if its a directory or file
		msg_warn "  ! ${target} exists. We will first backup to ${target}.bak"
		confirm || {
			msg_warn "  ! Skipping..."
			return 0
		}
		mv "${target}" "${target}.bak"
	fi

	ln -s "${real_file}" "${target}"
	msg_success "  -> Symlink created!"
}

load_cargo() {
	local cargo_path="${HOME}/.cargo/env"

	[[ ! $(command -v cargo) && -e "$cargo_path" ]] && source "$cargo_path"

	# If it still does not exist, return err
	[[ ! $(command -v cargo) ]] && return 1

	return 0
}

setup_dependencies() {
	install_dependencies() {
		local dependencies=("wget" "fzf" "unzip" "ripgrep" "fd" "bat" "git" "ipcalc" "finger" "tldr")
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

	confirm && install_dependencies
}

setup_eza() {
	install_eza() {
		load_cargo || {
			msg_err "  -> cargo command not found! eza installation require cargo."
			return 0
		}
		cargo install eza
	}

	if [[ $(command -v eza) ]]; then
		msg_info "  -> already installed, skipping..."
	else
		msg "  Installing eza"
		confirm && install_eza
	fi
}

setup_lazygit() {
	install_lazygit() {
		if [[ "${OSTYPE}" =~ ^darwin ]]; then
			brew install lazygit
		elif [[ "${OSTYPE}" =~ ^linux ]]; then
			LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
			curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
			tar xf lazygit.tar.gz lazygit
			sudo install lazygit /usr/local/bin

			# Clean up
			[[ ! -e "lazygit.tar.gz" ]] || rm lazygit.tar.gz
		fi
	}

	if [[ $(command -v lazygit) ]]; then
		msg_info "  -> already installed, skipping..."
	else
		msg "  Installing lazygit"
		confirm && install_lazygit
	fi

}

setup_pyenv() {
	install_pyenv() {
		if [[ "${OSTYPE}" =~ ^darwin ]]; then
			brew install pyenv
		elif [[ "${OSTYPE}" =~ ^linux ]]; then
			git clone https://github.com/pyenv/pyenv.git "${HOME}"/.pyenv
		fi
	}

	if [[ $(command -v pyenv) ]]; then
		msg_info "  -> already installed, skipping..."
	else
		msg "  Installing pyenv"
		confirm && install_pyenv
	fi
}

setup_bob() {
	install_bob() {
		load_cargo || {
			msg_err "  -> cargo command not found! bob installation require cargo."
			return 0
		}
		cargo install --git https://github.com/MordechaiHadad/bob.git
	}

	if [[ $(command -v bob) ]]; then
		msg_info "  -> already installed, skipping..."
	else
		msg "  Installing Bob"
		confirm && install_bob
	fi
}

setup_neovim() {
	safe_remove_nvim_caches() {
		local timestamp=$(date '+%s')
		local cache_locations=("${HOME}/.local/share/nvim" "${HOME}/.local/state/nvim" "${HOME}/.cache/nvim")

		for cache_location in "${cache_locations[@]}"; do
			if [[ -e "${cache_location}" ]]; then
				msg_info "${cache_location} exists. We will back up to ${cache_location}.bak.${timestamp}"
				mv "${cache_location}" "${cache_location}.bak.${timestamp}"
			fi
		done
	}

	install_nvim() {
		if [[ ! $(command -v bob) ]]; then
			msg_err "  -> bob command not found! neovim installation require Bob."
			return 0
		fi

		bob install "${NEOVIM_TAG}"
		bob use "${NEOVIM_TAG}"
	}

	if [[ $(command -v nvim) ]]; then
		local nvim_version=$(nvim --version | head -1 | grep -o '[0-9]\.[0-9]\.[0-9]')
		if [[ "$nvim_version" != "${NEOVIM_TAG}" ]]; then
			msg_warn "  ! detected Neovim of version ${nvim_version}. Do you want to change the version to '$NEOVIM_TAG'?"
			confirm || {
				msg_info "  -> Skipping neovim version change"
				return 0
			}

			install_nvim
			msg_success "  -> Changed Neovim version from '$nvim_version' to '$NEOVIM_TAG'"
		else
			msg_info "  -> already installed, skipping..."
		fi
	else
		msg "  Removing Neovim caches (if exist). Existing caches may interfere with subsequent package installations."
		confirm && safe_remove_nvim_caches

		msg "  Installing Neovim"
		confirm && install_nvim
	fi
}

setup_zsh() {
	install_zsh() {
		if [[ "${OSTYPE}" =~ ^darwin ]]; then
			sudo brew install zsh
		elif [[ "${OSTYPE}" =~ ^linux ]]; then
			sudo apt install -y zsh
		fi
	}

	configure_zsh() {
		local user_default_shell=$(finger "${USER_EXECUTOR}" | grep -o "Shell: .*" | cut -d" " -f2 | xargs basename)
		if [[ "$user_default_shell" != "zsh" ]]; then
			msg "  Setting zsh as default terminal"
			sudo chsh -s "$(which zsh)" "${USER_EXECUTOR}"
		else
			msg_info "  -> already set as default shell, skipping..."
		fi
	}

	if [[ $(command -v zsh) ]]; then
		msg_info "  -> already installed, skipping..."
	else
		msg "  Installing zsh"
		confirm && install_zsh
	fi

	msg "  Configuring zsh"
	configure_zsh
}

setup_rust() {
	install_rust() {
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	}

	if [[ $(command -v rustup) ]]; then
		msg_info "  -> already installed, skipping..."
	else
		msg "  Installing rust"
		confirm && install_rust
	fi
}

setup_go() {
	install_go() {
		local golang_pkg="go${GOLANG_TAG}.${GOLANG_SYS}.tar.gz"
		wget "https://go.dev/dl/${golang_pkg}"

		sudo tar -C /usr/local/ -xzf "${golang_pkg}"

		# Clean up
		[[ ! -e "${golang_pkg}" ]] || rm -rf "${golang_pkg}"
	}

	if [[ $(command -v go) ]]; then
		local go_version=$(go version | grep -oE '[0-9]\.[0-9]+\.[0-9]+')
		if [[ "$go_version" == "${GOLANG_TAG}" ]]; then
			msg_info "  -> already installed, skipping..."
		else
			# Version mismatch, upgrade
			msg_warn "  ! detected Golang of version ${go_version}. Removing existing installation."
			confirm || {
				msg_warn "  ! aborted removal of Golang. Skipping Golang setup."
				return 0
			}
			sudo rm -rf /usr/local/go

			msg "  Installing Golang"
			confirm && install_go
		fi
	else
		if [[ -d "/usr/local/go" ]]; then
			msg_warn "  ! Existing go directory is present at /usr/local/go. We need to remove the directory completely to proceed."
			confirm || {
				msg_warn "  ! aborted removal of Golang. Skipping Golang setup."
				return 0
			}
			sudo rm -rf /usr/local/go
		fi

		msg "  Installing Golang"
		confirm && install_go
	fi
}

setup_gitdelta() {
	install_gitdelta() {
		curl -sS https://webi.sh/delta | sh
	}

	if [[ $(command -v delta) ]]; then
		msg_info "  -> already installed, skipping..."
	else
		msg "  Installing git-delta"
		confirm && install_gitdelta
	fi
}

setup_git() {
	set_git_conf() {
		local git_location=$1
		local git_conf_name=$2
		local git_conf_cmd=$3
		local git_add_conf=${4-0}

		msg "  Setting $git_location: $git_conf_name = $git_conf_cmd"

		local git_conf_execute_cmd="git config $git_location $git_conf_name '$git_conf_cmd'"
		if [[ "$git_add_conf" -ne 0 ]]; then
			git_conf_execute_cmd="git config $git_location --add $git_conf_name '$git_conf_cmd'"
		fi

		local git_conf_existing_cmd=$(bash -c "git config $git_location --get $git_conf_name") || 0
		if [[ -n "$git_conf_existing_cmd" ]] && [[ "$git_conf_existing_cmd" =~ $git_conf_cmd ]]; then
			msg_info "  -> Config already exist"
		elif [[ -n "$git_conf_existing_cmd" ]] && [[ "$git_add_conf" -eq 0 ]]; then
			msg_warn "  ! Config is already used. To overwrite it, you can execute:"
			msg_warn "  ! $git_conf_execute_cmd"
		else
			bash -c "$git_conf_execute_cmd"
			msg_success "  -> Config set!"
		fi
	}

	handle_git_user_info() {
		if [[ -z "$GIT_USER" ]]; then
			msg_warn "  ! git user.name is not supplied."
			read -r -p "  ? Please input your git user.name: " git_username_input
			GIT_USER="$git_username_input"
		fi
		if [[ -z "$GIT_USER_EMAIL" ]]; then
			msg_warn "  ! git user.email is not supplied."
			read -r -p "  ? Please input your git user.email: " git_user_email_input
			GIT_USER_EMAIL="$git_user_email_input"
		fi
	}

	confirm || {
		msg_info "  -> Skipping git configuration"
		return 0
	}

	msg "  Checking user information"
	handle_git_user_info

	# Global user configuration
	set_git_conf "--global" "include.path" "${HOME}/.gitconfig-base" 1
	set_git_conf "--global" "include.path" "${HOME}/.gitconfig-themes" 1

	# User identity
	local git_location_flag="--global"

	if [[ -n "$GIT_USER_LOCAL_FILE" ]]; then
		msg "  Local user configuration to be set at ${GIT_USER_LOCAL_FILE}"
		git_location_flag="-f '$GIT_USER_LOCAL_FILE'"

		if [[ ! -e "$GIT_USER_LOCAL_FILE" ]]; then
			touch "$GIT_USER_LOCAL_FILE"
			msg_info "  -> Created local file at $GIT_USER_LOCAL_FILE"
		fi
	fi

	set_git_conf "$git_location_flag" "user.name" "$GIT_USER" 0
	set_git_conf "$git_location_flag" "user.email" "$GIT_USER_EMAIL" 0
}

setup_local_config() {
	if [[ ! -d "$LOCAL_CONFIG_DIR" ]]; then
		mkdir -p "$LOCAL_CONFIG_DIR"
		msg_success "  -> Created directory for local configs at $LOCAL_CONFIG_DIR"
	fi
}

setup_colors

msg_info "Beginning setup..."
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
	die "Unsupported OS: ${OSTYPE}"
fi

# Detected that script is executed under root.
# This will cause subsequent installation and configuration to be done for root user.
# Prompt for confirmation.
if [[ "${USER_EXECUTOR}" == "root" ]]; then
	die "Script is executed as ${USER_EXECUTOR}. Installation and configuration is not meant for system-level."
fi

# Dependencies installation
separator
msg_info "deps: installing dependencies"
setup_dependencies && msg_success "deps: success!"

# Git setup
separator
msg_info "git_conf: setting up Git configurations"
setup_git && msg_success "git_conf: success!"

# git-delta installation
separator
msg_info "git-delta: installing git-delta (syntax highlighter for git, diff, and grep output)"
setup_gitdelta && msg_success "git-delta: success!"

# Lazygit installation
separator
msg_info "lazygit: installing lazygit (simple terminal UI for git commands)"
setup_lazygit && msg_success "lazygit: success!"

# Pyenv installation
separator
msg_info "pyenv: installing pyenv (Python version manager)"
setup_pyenv && msg_success "pyenv: success!"

# Golang installation
separator
msg_info "Golang: installing Golang version ${GOLANG_TAG}"
setup_go && msg_success "Golang: success!"

# Rust installation
separator
msg_info "Rust: installing Rust (programming language) with rustup"
setup_rust && msg_success "Rust: success!"

# Exa installation
separator
msg_info "eza: installing eza (better ls). Require rust."
setup_eza && msg_success "eza: success!"

# Bob installation
separator
msg_info "bob: installing Bob (Neovim version manager). Require rust."
setup_bob && msg_success "Bob: success!"

# Neovim installation
separator
msg_info "Neovim: installing Neovim version '${NEOVIM_TAG}'"
setup_neovim && msg_success "Neovim: success!"

# ZSH installation
separator
msg_info "zsh: installing Z-Shell"
setup_zsh && msg_success "zsh: success!"

# Create directory to hold local configs
separator
msg_info "local_configs: setting up local config directory at $LOCAL_CONFIG_DIR. You can use it to place uncommited configurations."
setup_local_config && msg_success "local_configs: success!"

# Create symbolic link configuration
separator
msg_info "symlink: setting up soft links to repository configuration"
safe_symlink "${SCRIPT_DIR}/gitconfig/gitconfig-base" "${HOME}/.gitconfig-base"
safe_symlink "${SCRIPT_DIR}/gitconfig/gitconfig-themes" "${HOME}/.gitconfig-themes"
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
