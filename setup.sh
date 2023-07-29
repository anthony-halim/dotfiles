#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
	cat <<EOF # remove the space between << and EOF, this is due to web plugin issue
Setup dependencies and personal configurations.

Available options:

-h, --help      Print this help and exit
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

YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt)
BREW_CMD=$(which brew)

pkg_manager=""

if [[ -z $(which yum) ]]; then

# Install dependencies
dependencies=( "fzf" "ripgrep" )

for dependency in "${!dependencies[@]}"
do  
  if [[ ! -z $YUM_CMD ]]; then
    yum Install "$dependency"
  elif [[ ! -z $APT_GET_CMD ]]; then
    apt install -y "$dependency"
  elif [[ ! -z $BREW_CMD ]]; then
    brew install "$dependency"
  else
    die "unable to find package manager"
done

# Create softlinks
[[ ! -f "${script_dir}/.p10k.zsh" ]] || ln -s "${script_dir}/.p10k.zsh" "${HOME}/.p10k.zsh"
[[ ! -f "${script_dir}/.gitconfig" ]] || ln -s "${script_dir}/.gitconfig" "${HOME}/.gitconfig"
[[ ! -f "${script_dir}/.alias" ]] || ln -s "${script_dir}/.alias" "${HOME}/.alias"
[[ ! -f "${script_dir}/.zshrc" ]] || ln -s "${script_dir}/.zshrc" "${HOME}/.zshrc"

