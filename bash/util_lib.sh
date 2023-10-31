#!/bin/bash

###
#
# Setup
#
###

noformat=''
red=''
green=''
orange=''
blue=''
purple=''
cyan=''
yellow=''

setup::colors() {
	if [[ -t 2 ]] && [[ "${TERM-}" != "dumb" ]]; then
		# shellcheck disable=SC2034
		noformat='\033[0m' red='\033[0;31m' green='\033[0;32m' orange='\033[0;33m' blue='\033[0;34m' purple='\033[0;35m' cyan='\033[0;36m' yellow='\033[1;33m'
	fi
}

###
#
# Logging
#
###

log::log() {
	echo >&2 -e "$@"
}

log::info() {
	# shellcheck disable=SC2145
	log::log "${blue} INFO:\t\t$@${noformat}"
}

log::warn() {
	# shellcheck disable=SC2145
	log::log "${orange} WARN:\t\t$@${noformat}"
}

log::err() {
	# shellcheck disable=SC2145
	log::log "${red} ERROR:\t$@${noformat}"
}

log::success() {
	# shellcheck disable=SC2145
	log::log "${green} SUCCESS:\t$@${noformat}"
}

log::fatal() {
	# shellcheck disable=SC2145
	log::log "${red}󱚡 FATAL:\t$@${noformat}"
	exit 1
}

log::separator() {
	log::log "${yellow}─────────────────────────────────────────────────────────────────${noformat}"
}

###
#
# Input
#
###

input::prompt_confirmation() {
	# shellcheck disable=SC2145
	log::log "${yellow}$@${noformat}"
	while true; do
		read -r -p "(y/n): " yn
		case $yn in
		[Yy]*) return 0 ;;
		[Nn]*) return 1 ;;
		*) log::log "${yellow}Please answer [y]es or [n]o.${noformat}" ;;
		esac
	done
}

###
#
# Parser
#
###

parser::extract_semver() {
	local semver_input="$1"
	echo "$(echo "$semver_input" | grep -oE '[0-9]\.[0-9]+\.[0-9]+')"
}

###
#
# Git
#
###

git::fetch_latest_tag() {
	local repo="$1"
	local tag_pattern="${2:-*.*.*}"
	local latest_tag=""
	local cmd="git -c 'versionsort.suffix=-' ls-remote --exit-code --refs --sort=version:refname --tags $repo $tag_pattern | tail -n 1 | cut -d/ -f3"
	latest_tag=$(bash -c "$cmd")

	echo "$latest_tag"
}

git::set() {
	local git_location="$1"
	local git_conf_name="$2"
	local git_conf_cmd="$3"
	local git_add_conf="${4-0}"

	log::info "Setting $git_location: $git_conf_name = $git_conf_cmd"

	local flags=""
	if [[ "$git_add_conf" -ne 0 ]]; then
		flag+="--add"
	fi

	# Create command
	local git_conf_execute_cmd="git config $git_location $flags $git_conf_name '$git_conf_cmd'"

	# Check if already configured
	local git_conf_existing_cmd
	git_conf_existing_cmd=$(bash -c "git config $git_location --get $git_conf_name") || 0
	if [[ "$git_conf_existing_cmd" =~ $git_conf_cmd ]]; then
		# Already configured
		log::info "Config already exist."
	elif [[ -n "$git_conf_existing_cmd" && "$git_add_conf" -eq 0 ]]; then
		# Configured and we do not enable adding
		log::warn "Config is already used. To overwrite it, you can execute:"
		log::warn "$git_conf_execute_cmd"
	else
		bash -c "$git_conf_execute_cmd"
		log::success "Config set!"
	fi
}

###
#
# Symlink
#
###

symlink::safe_create() {
	local real_target="$1"
	local symlink_target="$2"

	log::info "Setting up $symlink_target -> $real_target"

	if [[ -L "${symlink_target}" && $(readlink -n "${symlink_target}") == "${real_target}" ]]; then
		log::info "Symlink already exist."
		return
	fi

	# Create backup symlink
	if [[ -L "${symlink_target}" ]]; then
		input::prompt_confirmation "${symlink_target} is another symlink. We will create a symlink ${symlink_target}.bak to original target. Do you want to proceed?" || {
			log::info "Skipping..."
			return
		}
		ln -s "$(readlink -n "${symlink_target}")" "${symlink_target}.bak" && rm "${symlink_target}"
	fi

	# Back up if its a directory or file
	if [[ -f "${symlink_target}" || -d "${symlink_target}" ]]; then
		input::prompt_confirmation "${symlink_target} exists. We will first backup to ${symlink_target}.bak. Do you want to proceed?" || {
			log::info "Skipping..."
			return
		}
		mv "${symlink_target}" "${symlink_target}.bak"
	fi

	# Create parent directory if needed
	mkdir -p "$(dirname "${symlink_target}")"

	# Finally create symlink
	log::info "Creating symlink $symlink_target -> $real_target"
	ln -s "${real_target}" "${symlink_target}"
	log::success "Symlink created!"
}

###
#
# Environment
#
###

env::load_cmd_if_not_exist() {
	local cmd="$1"
	local source_path="$2"

	# shellcheck disable=SC1090
	[[ ! $(command -v "$1") && -e "$source_path" ]] && source "$source_path"

	# If it still does not exist, return err
	[[ ! $(command -v "$1") ]] && return 1

	return 0
}

###
#
# Directory
#
###

dir::create_with_confirmation() {
	local dir_to_create="$1"
	local description="${2:-}"

	local msg="Setting up $dir_to_create."
	if [[ -n "$description" ]]; then
		msg+=" Description: $description"
	fi

	log::log "$msg"

	if [[ ! -d "$dir_to_create" ]]; then
		input::prompt_confirmation "Do you want to proceed?" || {
			log::warn "Skipping..."
			return 0
		}
		mkdir -p "$dir_to_create"
		log::success "Created directory: $dir_to_create."
	else
		log::info "Directory already exist, skipping."
	fi
}
