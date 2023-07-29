#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

USER_EXECUTOR=$(whoami)
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
	cat <<EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(
		basename "${BASH_SOURCE[0]}"
	) [-h] [-v] [--disable_pwless_sudo] [--py_version python_semver] [--neovim_tag neovim_semver]

Setup dependencies and setup local configuration.

Available options:

-h, --help                Print this help and exit
-v, --verbose             Print script debug info
--disable_pwless_sudo     [FLAG] Skip configuring current user to have passwordless sudo access.
--py_version              [Optional] [semver, x.x.x] Indicate python version to be set globally. Defaults to 3.8.5.
--neovim_tag              [Optional] [semver, x.x.x] Indicate NeoVim tag to be installed. Defaults to 0.9.1.
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

msg() {
	echo >&2 -e "${1-}"
}

die() {
	local msg=$1
	local code=${2-1} # default :exit status 1
	msg "$msg"
	exit "$code"
}

parse_params() {
	# default values of variables set from params
	NEOVIM_TAG="0.9.1"
	PY_GLOBAL_VER="3.8.5"
	IS_SKIP_SUDO=0

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		--disable_pwless_sudo) IS_SKIP_SUDO=1 ;;
		--py_version)
			PY_GLOBAL_VER="${2-}"
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

parse_params "$@"
setup_colors

msg "${RED}Read parameters:${NOFORMAT}"
msg "- neovim_tag: ${NEOVIM_TAG}"
msg "- py_global_ver: ${PY_GLOBAL_VER}"
msg "- disable_pwless_sudo: ${IS_SKIP_SUDO}"

# Check OS
if [[ ! "${OSTYPE}" =~ ^linux ]] && [[ ! "${OSTYPE}" =~ ^darwin ]]; then
  msg "${RED}Unsupported OS: ${OSTYPE}${NOFORMAT}"
  die
fi

# Passwordless sudo
if [[ "${IS_SKIP_SUDO}" -ne 1 ]]; then
	msg "Configuring passwordless sudo for user: ${USER_EXECUTOR}"

	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		msg "${ORANGE}For MacOS, please use visudo to add to sudoers!${NOFORMAT}"

	elif [[ "${OSTYPE}" =~ ^linux ]]; then
		sudoers_file="/etc/sudoers.d/${USER_EXECUTOR}"
		touch "${sudoers_file}"
		echo "${USER_EXECUTOR} ALL=(ALL) NOPASSWD:ALL" >"${sudoers_file}"
		chown root:root "$sudoers_file"
		chmod 440 "$sudoers_file"

		msg "Success: configured passwordless sudo!"
	fi
fi

# Dependencies installation
msg "Installing dependencies"
dependencies=("lazygit" "fzf" "ripgrep" "fd")
for dependency in "${!dependencies[@]}"; do
	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		brew install "${dependency}"
	elif [[ "${OSTYPE}" =~ ^linux ]]; then
		if [[ "${dependency}" == "fd" ]]; then dependency="fd-find"; fi
		apt install -y "${dependency}"
	fi
done

# Pyenv installation
if [[ ! $(command -v pyenv) ]]; then
	msg "Installing pyenv"

	if [[ -d "${HOME}"/.pyenv ]]; then rm -rf "${HOME}"/.pyenv; fi

	if [[ "${OSTYPE}" =~ ^darwin ]]; then
		brew install pyenv

	elif [[ "${OSTYPE}" =~ ^linux ]]; then
		source <(curl https://pyenv.run)
	fi

	msg "Success: Installed pyenv!"
	msg "Setting up global python version: ${PY_GLOBAL_VER}"

	eval "$(pyenv init --path)"
	eval "$(pyenv init -)"

	pyenv install "${PY_GLOBAL_VER}"
	pyenv global "${PY_GLOBAL_VER}"

	msg "Success: set up global python version: ${PY_GLOBAL_VER}"
fi

# NeoVim installation
if [[ ! $(command -v nvim) ]]; then
	msg "Installing NeoVim: ${NEOVIM_TAG}"

  # Remove all existing configuration
	if [[ -d "${HOME}"/.local/share/nvim ]]; then rm -rf "${HOME}"/.local/share/nvim; fi
	if [[ -d "${HOME}"/.local/state/nvim ]]; then rm -rf "${HOME}"/.local/state/nvim; fi
	if [[ -d "${HOME}"/.cache/nvim ]]; then rm -rf "${HOME}"/.cache/nvim; fi

	if [[ "${OSTYPE}" =~ ^darwin ]]; then
    binary_release="nvim-macos"
	elif [[ "${OSTYPE}" =~ ^linux ]]; then
    binary_release="nvim-linux64"

  wget "https://github.com/neovim/neovim/releases/download/v${NEOVIM_TAG}/${binary_release}.tar.gz"
  
  if [[ "${OSTYPE}" =~ ^darwin ]]; then
    # Avoid unknown developer warning
    xattr -c "./${binary_release}.tar.gz"
  fi

  tar xzvf "${binary_release}.tar.gz"
  mv "${binary_release}" /usr/share
  ln -sf "/usr/share/${binary_release}/bin/nvim" /usr/bin/nvim

  msg "Success: installed NeoVim!"
fi

# ZSH and OMZ Installation

# Link configuration

