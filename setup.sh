#!/usr/bin/env bash

set -Eeuo pipefail
trap catch_err ERR
trap cleanup SIGINT SIGTERM EXIT

# Constants
USER_EXECUTOR=$(whoami)
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

# Load required libs
source "$SCRIPT_DIR/bash/util_lib.sh"

# Default arguments
GIT_USER=""
GIT_USER_EMAIL=""
GIT_USER_LOCAL_FILE=""
NEOVIM_TAG="latest"
GOLANG_TAG="latest"
LOCAL_CONFIG_DIR="$HOME/.config/zsh/local_config"
NOTES_PERSONAL_DIR="$HOME/notes/personal"
NOTES_WORK_DIR="$HOME/notes/work"
REPO_PERSONAL_DIR="$HOME/repos/personal"
REPO_WORK_DIR="$HOME/repos/work"

usage() {
	cat <<EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(
		basename "${BASH_SOURCE[0]}"
	) [-h] [-v] [--git_user git_user] [--git_user_email git_user_email] [--git_user_local_file path_to_file] 
                [--golang_tag golang_semver] 
                [--neovim_tag neovim_semver]

Setup dependencies and setup local configuration for the user.

IMPORTANT: Not to be executed as sudo. These configurations are meant for user-level configuration.

Available options:

--git_user                [Optional] [string]          Indicate git user. If empty, will be prompted later.
--git_user_email          [Optional] [string]          Indicate git user email. If empty, will be prompted later.
--git_user_local_file     [Optional] [string]          Configure git user and git email to a local file instead of the user's global .gitconfig. 
                                                       If empty, will default to global .gitconfig. 
                                                       Suitable for users who uses multiple gitconfigs.

--golang_tag              [Optional] [semver, gox.x.x] Indicate Golang version to be installed. Defaults to $GOLANG_TAG.

--neovim_tag              [Optional] [semver, vx.x.x]  Indicate Neovim tag to be installed. Defaults to $NEOVIM_TAG.

-h, --help                                             Print this help and exit
-v, --verbose             [FLAG]                       Print script debug info
EOF
	exit
}

cleanup() {
	trap - SIGINT SIGTERM EXIT
	# script cleanup here
}

catch_err() {
	cleanup
	log::fatal "$(caller): Execution failed at this line."
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
		--neovim_tag)
			NEOVIM_TAG="${2-}"
			shift
			;;
		-?*) log::fatal "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")

	# Expand path
	GIT_USER_LOCAL_FILE="${GIT_USER_LOCAL_FILE/#\~/$HOME}"

	return 0
}

log_params() {
	# Log parameters
	local script_parameters=""
	script_parameters+="user=${USER_EXECUTOR}"
	script_parameters+=", golang_tag=${GOLANG_TAG}"
	script_parameters+=", neovim_tag=${NEOVIM_TAG}"
	script_parameters+=", git_user=${GIT_USER}"
	script_parameters+=", git_user_email=${GIT_USER_EMAIL}"
	script_parameters+=", git_user_local_file=${GIT_USER_LOCAL_FILE}"

	log::info "Script Parameters: $script_parameters"
}

setup_dependencies() {
	# Installation
	need_installation_predicate() {
		# Always install
		echo 0
	}
	install_func() {
		local dependencies=("wget" "unzip" "ripgrep" "fd" "bat" "git" "ipcalc" "finger" "tldr")
		for dependency in "${dependencies[@]}"; do
			log::info "Installing '$dependency'"
			if [[ "${OSTYPE}" =~ ^darwin ]]; then
				brew install "${dependency}" >/dev/null 2>&1
			elif [[ "${OSTYPE}" =~ ^linux ]]; then
				if [[ "${dependency}" == "fd" ]]; then dependency="fd-find"; fi
				sudo apt install -y "${dependency}" >/dev/null 2>&1
			fi
		done
	}

	# Upgrade
	need_upgrade_predicate() {
		# No upgrade for this
		echo 1
	}
	upgrade_func() {
		return
	}

	# Configuration
	configure_func() {
		tldr update
	}

	pkg::setup_wrapper "deps" "common dependencies and tools" need_installation_predicate install_func need_upgrade_predicate upgrade_func configure_func
}

setup_fzf() {
	local target_fzf_version="${1:-latest}"

	# Parameter checks
	if [[ "$target_fzf_version" == "latest" ]]; then
		target_fzf_version=$(git::fetch_latest_tag "https://github.com/junegunn/fzf" "*.*.*")
		log::info "Translated fzf: 'latest' to '$target_fzf_version'"
	fi
	if ! [[ "$target_fzf_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		log::err "Invalid format for fzf tag, must be x.x.x"
		return 0
	fi

	local target_fzf_sys=""
	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		target_fzf_sys="darwin_amd64"
	elif [[ "${OSTYPE}" =~ ^linux ]]; then
		target_fzf_sys="linux_amd64"
	fi

	# Installation
	need_installation_predicate() {
		if [[ ! $(command -v fzf) ]]; then
			echo 0
		else
			echo 1
		fi
	}
	install_func() {
		curl -Lo fzf.tar.gz "https://github.com/junegunn/fzf/releases/download/$target_fzf_version/fzf-$target_fzf_version-$target_fzf_sys.tar.gz"
		tar xf fzf.tar.gz fzf

		pkg::softlink_local_bin "${SCRIPT_DIR}/fzf" "$target_fzf_version"

		# Clean up
		[[ ! -f "fzf.tar.gz" ]] || rm fzf.tar.gz
		[[ ! -f "fzf" ]] || rm fzf
	}

	# Upgrade
	need_upgrade_predicate() {
		local fzf_version=$(fzf --version | cut -d' ' -f1)
		if [[ "$fzf_version" != "${target_fzf_version}" ]]; then
			log::warn "Attempting to upgrade fzf version from '$fzf_version' to '$target_fzf_version'"
			echo 0
		else
			echo 1
		fi
	}
	upgrade_func() {
		install_func
		return
	}

	# Configuration
	configure_func() {
		return
	}

	pkg::setup_wrapper "fzf" "fuzzy file finder" need_installation_predicate install_func need_upgrade_predicate upgrade_func configure_func
}

setup_eza() {
	# Installation
	need_installation_predicate() {
		if [[ ! $(command -v eza) ]]; then
			echo 0
		else
			echo 1
		fi
	}
	install_func() {
		env::load_cmd_if_not_exist "cargo" "${HOME}/.cargo/env" || {
			log::err "cargo command not found! eza installation require cargo."
			return 0
		}
		cargo install eza
	}

	# Upgrade
	need_upgrade_predicate() {
		# TODO: Check version
		echo 1
	}
	upgrade_func() {
		return
	}

	# Configuration
	configure_func() {
		return
	}

	pkg::setup_wrapper "eza" "better ls" need_installation_predicate install_func need_upgrade_predicate upgrade_func configure_func
}

setup_zellij() {
	local target_zellij_version="latest"
	local zellij_repo="https://github.com/zellij-org/zellij"
	local zellij_tag="latest"
	local zellij_tag_pattern="v*.*.*"
	local zellij_bin_pattern=""
	local zellij_bin_name="zellij"

	# Tag check
	if [[ "$zellij_tag" == "latest" ]]; then
		zellij_tag=$(git::fetch_latest_tag "$zellij_repo" "$zellij_tag_pattern")
		log::info "Translated zellij: 'latest' to '$zellij_tag'"
	fi
	if ! [[ "$zellij_tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		log::err "Invalid format for zellij tag, must be vx.x.x"
		return 0
	fi

	# Binary target pattern
	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		zellij_bin_pattern="zellij-x86_64-apple-darwin.tar.gz"
	elif [[ "${OSTYPE}" =~ ^linux ]]; then
		zellij_bin_pattern="zellij-x86_64-unknown-linux-musl.tar.gz"
	fi

	# Installation
	need_installation_predicate() {
		if [[ ! $(command -v zellij) ]]; then
			echo 0
		else
			echo 1
		fi
	}
	install_func() {
		pkg::fetch_git_tag_release "$zellij_repo" "$zellij_tag" "$zellij_bin_pattern" "$zellij_bin_name"
	}

	# Upgrade
	need_upgrade_predicate() {
		local zellij_cur_version=$(zellij --version | cut -d' ' -f2)
		if [[ "v$zellij_cur_version" != "${zellij_tag}" ]]; then
			log::warn "Attempting to upgrade zellij version from 'v$zellij_cur_version' to '$zellij_tag'"
			echo 0
		else
			echo 1
		fi
	}
	upgrade_func() {
		install_func
		return
	}

	# Configuration
	configure_func() {
		symlink::safe_create "${SCRIPT_DIR}/zellij" "${HOME}/.config/zellij"
	}

	pkg::setup_wrapper "zellij" "terminal session manager and terminal multiplexer" need_installation_predicate install_func need_upgrade_predicate upgrade_func configure_func
}

setup_zjstatus() {
	local target_zjstatus_version="${1:-latest}"
	local zjstatus_bin="${2:-zjstatus.wasm}"
	local zellij_plugin_dir="${3:-$HOME/.local/share/zellij/plugins}"

	# Parameter checks
	if [[ "$target_zjstatus_version" == "latest" ]]; then
		target_zjstatus_version=$(git::fetch_latest_tag "https://github.com/dj95/zjstatus" "v*.*.*")
		log::info "Translated zjstatus: 'latest' to '$target_zjstatus_version'"
	fi
	if ! [[ "$target_zjstatus_version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		log::err "Invalid format for zjstatus tag, must be vx.x.x"
		return 0
	fi

	# Installation
	need_installation_predicate() {
		if [[ ! -e "$zellij_plugin_dir/$zjstatus_bin" ]]; then
			echo 0
		else
			echo 1
		fi
	}
	install_func() {
		curl -Lo "$zjstatus_bin" "https://github.com/dj95/zjstatus/releases/download/${target_zjstatus_version}/${zjstatus_bin}"

		pkg::softlink_local_bin "${SCRIPT_DIR}/$zjstatus_bin" "$target_zjstatus_version" "$zjstatus_bin" "$zellij_plugin_dir"

		# Clean up
		[[ ! -f "$zjstatus_bin" ]] || rm "$zjstatus_bin"
	}

	# Upgrade
	need_upgrade_predicate() {
		if ! [[ -L "$zellij_plugin_dir/$zjstatus_bin" ]]; then
			log::warn "Unable to parse version of zjstatus."
			echo 1
			return
		fi

		local current_zjstatus_dir=$(readlink -n "$zellij_plugin_dir/$zjstatus_bin")
		local zjstatus_version=$(dirname "$current_zjstatus_dir" | cut -d- -f2)
		if [[ "$zjstatus_version" != "${target_zjstatus_version}" ]]; then
			log::warn "Attempting to upgrade zjstatus version from '$zjstatus_version' to '$target_zjstatus_version'"
			echo 0
		else
			echo 1
		fi
	}
	upgrade_func() {
		install_func
		return
	}

	# Configuration
	configure_func() {
		return
	}

	pkg::setup_wrapper "zjstatus" "statusbar for Zellij" need_installation_predicate install_func need_upgrade_predicate upgrade_func configure_func
}

setup_lazygit() {
	local target_lazygit_version="${1:-latest}"

	# Parameter checks
	if [[ "$target_lazygit_version" == "latest" ]]; then
		target_lazygit_version=$(git::fetch_latest_tag "https://github.com/jesseduffield/lazygit" "v*.*.*")
		log::info "Translated lazygit: 'latest' to '$target_lazygit_version'"
	fi
	if ! [[ "$target_lazygit_version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		log::err "Invalid format for lazygit tag, must be vx.x.x"
		return 0
	fi

	# Installation
	need_installation_predicate() {
		if [[ ! $(command -v lazygit) ]]; then
			echo 0
		else
			echo 1
		fi
	}
	install_func() {
		if [[ "${OSTYPE}" =~ ^darwin ]]; then
			brew install lazygit
		elif [[ "${OSTYPE}" =~ ^linux ]]; then
			local truncated_version=$(input::remove_prefix_if_exist "$target_lazygit_version" "v")
			curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${truncated_version}_Linux_x86_64.tar.gz"
			tar xf lazygit.tar.gz lazygit

			pkg::softlink_local_bin "${SCRIPT_DIR}/lazygit" "v$truncated_version"

			# Clean up
			[[ ! -f "lazygit.tar.gz" ]] || rm lazygit.tar.gz
			[[ ! -f "lazygit" ]] || rm lazygit.tar.gz
		fi
	}

	# Upgrade
	need_upgrade_predicate() {
		local lazygit_version=$(lazygit --version | head -1 | grep -Eo ', version=([0-9]+\.[0-9]+\.[0-9]+)' | cut -d= -f2)
		if [[ "v$lazygit_version" != "${target_lazygit_version}" ]]; then
			log::warn "Attempting to upgrade lazygit version from 'v$lazygit_version' to '$target_lazygit_version'"
			echo 0
		else
			echo 1
		fi
	}
	upgrade_func() {
		install_func
		return
	}

	# Configuration
	configure_func() {
		return
	}

	pkg::setup_wrapper "lazygit" "simple terminal UI for git commands" need_installation_predicate install_func need_upgrade_predicate upgrade_func configure_func
}

setup_pyenv() {
	# Installation
	need_installation_predicate() {
		if [[ ! $(command -v pyenv) ]]; then
			echo 0
		else
			echo 1
		fi
	}
	install_func() {
		git clone https://github.com/pyenv/pyenv.git "${HOME}"/.pyenv
	}

	# Upgrade
	need_upgrade_predicate() {
		# TODO: Check version
		echo 1
	}
	upgrade_func() {
		return
	}

	# Configuration
	configure_func() {
		return
	}

	pkg::setup_wrapper "pyenv" "Python version manager" need_installation_predicate install_func need_upgrade_predicate upgrade_func configure_func
}

setup_bob() {
	# Installation
	need_installation_predicate() {
		if [[ ! $(command -v bob) ]]; then
			echo 0
		else
			echo 1
		fi
	}
	install_func() {
		env::load_cmd_if_not_exist "cargo" "${HOME}/.cargo/env" || {
			log::err "cargo command not found! bob installation require cargo."
			return 0
		}
		cargo install --git https://github.com/MordechaiHadad/bob.git
	}

	# Upgrade
	need_upgrade_predicate() {
		# TODO: Check version
		echo 1
	}
	upgrade_func() {
		return
	}

	# Configuration
	configure_func() {
		return
	}

	pkg::setup_wrapper "bob" "Neovim version manager" need_installation_predicate install_func need_upgrade_predicate upgrade_func configure_func
}

setup_neovim() {
	local target_nvim_version="${1:-latest}"

	# Parameter checks
	if [[ "$target_nvim_version" == "latest" ]]; then
		target_nvim_version=$(git::fetch_latest_tag "https://github.com/neovim/neovim" "v*.*.*")
		log::info "Translated neovim_tag: 'latest' to '$target_nvim_version'"
	fi
	if ! [[ "$target_nvim_version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		log::err "Invalid format for Neovim tag, must be vx.x.x"
		return 0
	fi

	# Installation
	need_installation_predicate() {
		if [[ ! $(command -v nvim) ]]; then
			echo 0
		else
			echo 1
		fi
	}
	install_func() {
		if [[ ! $(command -v bob) ]]; then
			log::err "bob command not found! Neovim installation require Bob."
			return 0
		fi

		# Remove caches if allowed
		input::prompt_confirmation "Removing existing Neovim caches, if any. Existing caches may interfere with subsequent package installation. Do you want to proceed?" && {
			local timestamp=$(date '+%s')
			local cache_locations=("${HOME}/.local/share/nvim" "${HOME}/.local/state/nvim" "${HOME}/.cache/nvim")

			for cache_location in "${cache_locations[@]}"; do
				if [[ -e "${cache_location}" ]]; then
					log::info "${cache_location} exists. We will back up to ${cache_location}.bak.${timestamp}"
					mv "${cache_location}" "${cache_location}.bak.${timestamp}"
				fi
			done
		}

		local truncated_version=$(input::remove_prefix_if_exist "$target_nvim_version" "v")
		bob install "${truncated_version}"
		bob use "${truncated_version}"
	}

	# Upgrade
	need_upgrade_predicate() {
		local nvim_version=$(nvim --version | head -1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
		if [[ "v$nvim_version" != "${target_nvim_version}" ]]; then
			log::warn "Attempting to upgrade Neovim version from 'v$nvim_version' to '$target_nvim_version'"
			echo 0
		else
			echo 1
		fi
	}
	upgrade_func() {
		install_nvim
		log::success "Changed Neovim version to '$target_nvim_version'"
		return
	}

	# Configuration
	configure_func() {
		return
	}

	pkg::setup_wrapper "Neovim" "text editor" need_installation_predicate install_func need_upgrade_predicate upgrade_func configure_func
}

setup_zsh() {
	# Installation
	need_installation_predicate() {
		if [[ ! $(command -v zsh) ]]; then
			echo 0
		else
			echo 1
		fi
	}
	install_func() {
		if [[ "${OSTYPE}" =~ ^darwin ]]; then
			sudo brew install zsh
		elif [[ "${OSTYPE}" =~ ^linux ]]; then
			sudo apt install -y zsh
		fi
	}

	# Upgrade
	need_upgrade_predicate() {
		# TODO: Check version
		echo 1
	}
	upgrade_func() {
		return
	}

	# Configuration
	configure_func() {
		local user_default_shell=$(finger "${USER_EXECUTOR}" | grep -o "Shell: .*" | cut -d" " -f2 | xargs basename)
		if [[ "$user_default_shell" != "zsh" ]]; then
			log::info "Setting zsh as default terminal"
			sudo chsh -s "$(which zsh)" "${USER_EXECUTOR}"
		else
			log::info "ZSH is already set as default shell"
		fi

		symlink::safe_create "${SCRIPT_DIR}/zsh" "${HOME}/.config/zsh"
		symlink::safe_create "${SCRIPT_DIR}/zsh/.zshrc" "${HOME}/.zshrc"
		symlink::safe_create "${SCRIPT_DIR}/zsh/.p10k.zsh" "${HOME}/.p10k.zsh"
	}

	pkg::setup_wrapper "ZSH" "shell" need_installation_predicate install_func need_upgrade_predicate upgrade_func configure_func
}

setup_zap() {
	# Installation
	need_installation_predicate() {
		# BUG: zap is not able to be detected via command -v
		# We check the installation path instead
		if [[ ! -x "${HOME}/.local/share/zap" ]]; then
			echo 0
		else
			echo 1
		fi
	}
	install_func() {
		if [[ ! $(command -v zsh) ]]; then
			log::err "ZSH command not found! Zap installation require ZSH."
			return 0
		fi
		zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1 --keep
	}

	# Upgrade
	need_upgrade_predicate() {
		# TODO: Check version
		echo 1
	}
	upgrade_func() {
		return
	}

	# Configuration
	configure_func() {
		return
	}

	pkg::setup_wrapper "Zap" "ZSH plugin manager" need_installation_predicate install_func need_upgrade_predicate upgrade_func configure_func
}

setup_rust() {
	# Installation
	need_installation_predicate() {
		if [[ ! $(command -v rustup) ]]; then
			echo 0
		else
			echo 1
		fi
	}
	install_func() {
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	}

	# Upgrade
	need_upgrade_predicate() {
		# TODO: Check version
		echo 1
	}
	upgrade_func() {
		return
	}

	# Configuration
	configure_func() {
		return
	}

	pkg::setup_wrapper "Rust" "programming language" need_installation_predicate install_func need_upgrade_predicate upgrade_func configure_func
}

setup_go() {
	local target_golang_tag="${1:-latest}"

	# Parameter checks
	if [[ "$target_golang_tag" == "latest" ]]; then
		target_golang_tag=$(git::fetch_latest_tag "https://github.com/golang/go" "go*.*.*")
		log::info "Translated golang_tag: 'latest' to '$target_golang_tag'"
	fi
	if ! [[ "$target_golang_tag" =~ ^go[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		log::err "Invalid format for Golang tag, must be gox.x.x"
		return 0
	fi

	local target_golang_sys=""
	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		target_golang_sys="darwin-amd64"
	elif [[ "${OSTYPE}" =~ ^linux ]]; then
		target_golang_sys="linux-amd64"
	fi

	# Installation
	need_installation_predicate() {
		if [[ ! $(command -v go) ]]; then
			echo 0
		else
			echo 1
		fi
	}
	install_func() {
		if [[ -d "/usr/local/go" ]]; then
			log::warn "Existing go directory is present at /usr/local/go."
			input::prompt_confirmation "We need to remove the directory to proceed. Do you want to proceed?" || {
				log::warn "Aborted removal of Golang. Skipping Golang setup."
				return 0
			}
			sudo rm -rf /usr/local/go
		fi

		local golang_pkg="${target_golang_tag}.${target_golang_sys}.tar.gz"
		wget "https://go.dev/dl/${golang_pkg}"

		sudo tar -C /usr/local/ -xzf "${golang_pkg}"

		# Clean up
		[[ ! -e "${golang_pkg}" ]] || rm -rf "${golang_pkg}"
	}

	# Upgrade
	need_upgrade_predicate() {
		local go_version=$(go version | grep -oE '[0-9]\.[0-9]+\.[0-9]+')
		if [[ "go$go_version" != "${target_golang_tag}" ]]; then
			log::warn "Attempting to upgrade Golang version from 'go$go_version' to '$target_golang_tag'"
			echo 0
		else
			echo 1
		fi
	}
	upgrade_func() {
		install_func
		log::success "Changed Golang version to '$target_golang_tag'"
	}

	# Configuration
	configure_func() {
		return
	}

	pkg::setup_wrapper "Golang" "programming language" need_installation_predicate install_func need_upgrade_predicate upgrade_func configure_func
}

setup_gitdelta() {
	# Installation
	need_installation_predicate() {
		if [[ ! $(command -v delta) ]]; then
			echo 0
		else
			echo 1
		fi
	}
	install_func() {
		curl -sS https://webi.sh/delta | sh
	}

	# Upgrade
	need_upgrade_predicate() {
		# TODO: Check version
		echo 1
	}
	upgrade_func() {
		return
	}

	# Configuration
	configure_func() {
		return
	}

	pkg::setup_wrapper "git-delta" "syntax highlighter for git, diff, and grep output" need_installation_predicate install_func need_upgrade_predicate upgrade_func configure_func
}

setup_git() {
	input::prompt_confirmation "Setting up Git configurations. Do you want to proceed?" || {
		log::info "Skipping git configuration."
		return 0
	}

	# Global user configuration
	git::set "--global" "include.path" "${HOME}/.gitconfig-base" 1
	git::set "--global" "include.path" "${HOME}/.gitconfig-themes" 1

	# Handle local file option
	local git_location_flag="--global"
	if [[ -n "$GIT_USER_LOCAL_FILE" ]]; then
		log::info "Local user configuration to be set at ${GIT_USER_LOCAL_FILE}"
		git_location_flag="-f '$GIT_USER_LOCAL_FILE'"

		if [[ ! -e "$GIT_USER_LOCAL_FILE" ]]; then
			touch "$GIT_USER_LOCAL_FILE"
			log::info "Created local file at $GIT_USER_LOCAL_FILE"
		fi
	fi

	# Handle user information
	if [[ -z "$GIT_USER" ]]; then
		log::warn "git user.name is not supplied."
		read -r -p "Please input your git user.name: " git_username_input
		GIT_USER="$git_username_input"
	fi
	if [[ -z "$GIT_USER_EMAIL" ]]; then
		log::warn "git user.email is not supplied."
		read -r -p "Please input your git user.email: " git_user_email_input
		GIT_USER_EMAIL="$git_user_email_input"
	fi

	# Set user identity
	git::set "$git_location_flag" "user.name" "$GIT_USER" 0
	git::set "$git_location_flag" "user.email" "$GIT_USER_EMAIL" 0

	# Setup symlink
	symlink::safe_create "${SCRIPT_DIR}/gitconfig/gitconfig-base" "${HOME}/.gitconfig-base"
	symlink::safe_create "${SCRIPT_DIR}/gitconfig/gitconfig-themes" "${HOME}/.gitconfig-themes"

	log::success "Finished setting Git configurations."
}

setup_diatheke() {
	# Installation
	need_installation_predicate() {
		if [[ ! $(command -v diatheke) ]] || [[ ! $(command -v installmgr) ]]; then
			echo 0
		else
			echo 1
		fi
	}
	install_func() {
		if [[ "${OSTYPE}" =~ ^darwin ]]; then
			brew install sword
		elif [[ "${OSTYPE}" =~ ^linux ]]; then
			sudo apt install -y libsword-utils diatheke
		fi
	}

	# Upgrade
	need_upgrade_predicate() {
		# Last update was 2018
		echo 1
	}
	upgrade_func() {
		return
	}

	# Configuration
	configure_func() {
		if [[ ! $(command -v installmgr) ]]; then
			log::err "installmgr is not found"
			return 0
		fi

		export SWORD_PATH="${HOME}/.sword"
		local sword_mods="${SWORD_PATH}/mods.d"
		log::info "SWORD mods.d is set at: ${sword_mods}."
		mkdir -p "$sword_mods"

		input::prompt_confirmation "Initialising user config file. Do you want to proceed?" && {
			yes "yes" 2>/dev/null | installmgr -init # create a basic user config file
		}

		input::prompt_confirmation "Setting up installmgr with remote sources. Do you want to proceed?" && {
			yes "yes" 2>/dev/null | installmgr -sc # sync config with list of known remote repos
			log::success "Remote sources synced"
		}

		input::prompt_confirmation "Installing CrossWire's KJV Bible module. Do you want to proceed?" && {
			yes "yes" 2>/dev/null | installmgr -r CrossWire      # refresh remote source
			yes "yes" 2>/dev/null | installmgr -ri CrossWire KJV # install module from remote source
			log::success "CrossWire's KJV Bible module installed"
		}

		# Explicitly return 0, user skipping configuration is not an error
		return 0
	}

	pkg::setup_wrapper "diatheke" "CLI for the SWORD project, OSS Bible Software. Used for bible-verse.nvim" need_installation_predicate install_func need_upgrade_predicate upgrade_func configure_func
}

setup_wezterm() {
	# Installation
	need_installation_predicate() {
		# Wezterm has manual installation
		echo 1
	}
	install_func() {
		return
	}

	# Upgrade
	need_upgrade_predicate() {
		# Wezterm has manual installation
		echo 1
	}
	upgrade_func() {
		return
	}

	# Configuration
	configure_func() {
		symlink::safe_create "${SCRIPT_DIR}/wezterm/wezterm.lua" "${HOME}/.wezterm.lua"
		return
	}

	pkg::setup_wrapper "Wezterm" "cross-platform terminal emulator" need_installation_predicate install_func need_upgrade_predicate upgrade_func configure_func
}

setup::colors

# Check OS
if [[ ! "${OSTYPE}" =~ ^linux ]] && [[ ! "${OSTYPE}" =~ ^darwin ]]; then
	log::fatal "Unsupported OS: ${OSTYPE}"
fi

# Detected that script is executed under root.
# This will cause subsequent installation and configuration to be done for root user.
if [[ "${USER_EXECUTOR}" == "root" ]]; then
	log::fatal "Script is executed as ${USER_EXECUTOR}. Installation and configuration is not meant for system-level."
fi

log::info "Beginning setup..."
parse_params "$@"
log_params

# Dependencies setup
log::separator
setup_dependencies

# Git setup
log::separator
setup_git

# ZSH installation
log::separator
setup_zsh

# Zap installation
log::separator
setup_zap

# Zellij installation
log::separator
setup_zellij

# Zjstatus installation
log::separator
setup_zjstatus

# Wezterm setup
log::separator
setup_wezterm

# git-delta installation
log::separator
setup_gitdelta

# fzf setup
log::separator
setup_fzf

# Lazygit installation
log::separator
setup_lazygit

# Exa installation
log::separator
setup_eza

# Pyenv installation
log::separator
setup_pyenv

# Golang installation
log::separator
setup_go "$GOLANG_TAG"

# Rust installation
log::separator
setup_rust

# Bob installation
log::separator
setup_bob

# Neovim installation
log::separator
setup_neovim "$NEOVIM_TAG"

# diatheke installation
log::separator
setup_diatheke

# Create required directories
log::separator
log::log "directories: setting up directories"
dir::create_with_confirmation "$LOCAL_CONFIG_DIR" "directory to place uncommitted configurations (functions, aliases, env). Any *.zsh files in this directory will automatically be sourced."
dir::create_with_confirmation "$REPO_PERSONAL_DIR" "personal repository directory."
dir::create_with_confirmation "$REPO_WORK_DIR" "work repository directory."
dir::create_with_confirmation "$NOTES_PERSONAL_DIR" "personal notes vault (note directory)."
dir::create_with_confirmation "$NOTES_WORK_DIR" "work notes vault (note directory)."
log::success "directories: success!"

# Report git information at the very end to make it clear to user
if [[ -n "$GIT_USER_LOCAL_FILE" ]]; then
	log::separator
	log::info "You have set local git user configuration file. To include local git file, you can add the following to your global .gitconfig:"

	log::log " "
	log::log "# For global include"
	log::log "[include]"
	log::log "    path = $GIT_USER_LOCAL_FILE"
	log::log " "
	log::log "# Or, for conditional include"
	log::log "[includeIf \"gitdir:/path/to/dir/\"] # Change this!"
	log::log "    path = $GIT_USER_LOCAL_FILE"
	log::log " "
fi
