#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
	cat <<EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(
		basename "${BASH_SOURCE[0]}"
	)

Setup local home_configuration.
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
	flag=0
	param=''

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")

	# check required params and arguments
	[[ -z "${param-}" ]] && die "Missing required parameter: param"
	[[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

	return 0
}

parse_params "$@"
setup_colors

# Find package manager

pkg_manager_install_cmd=""
if [[ -z $(which yum) ]]; then
	pkg_manager_install_cmd="yum install"
elif [[ -z $(which apt-get) ]]; then
	pkg_manager_install_cmd="apt-get install -y"
elif [[ -z $(which brew) ]]; then
	pkg_manager_install_cmd="brew install"
else
	die "no known package manager detected"
fi

# Install dependencies

dependencies=("zsh" "git" "fzf" "ripgrep" "lazygit")

for dependency in "${!dependencies[@]}"; do
	${pkg_manager_install_cmd} ${dependency}
done

# Setup no password access to sudo

# Install pyenv

pyenv_script=$(curl https://pyenv.run)
sh
pyenv install 3.8.5
pyenv global 3.8.5

# Setup ZSH terminal

### Setup ZSH as default

chsh -s $(which zsh)

### Install OMZ and update

sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
omz update

### Install p10k theme

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

# Create softlinks for configurations

home_configurations=(".p10k.zsh" ".gitconfig" ".alias" ".zshrc")

for home_configuration in "${!home_configurations[@]}"; do
	[[ ! -f "${script_dir}/${home_configuration}" ]] || ln -s "${script_dir}/${home_configuration}" "${HOME}/${home_configuration}"
done
