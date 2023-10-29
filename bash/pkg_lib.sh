#!/usr/bin/env bash

pkg_lib_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

# Load required libs
source "$pkg_lib_dir/util_lib.sh"

###
#
# Package management
#
###

pkg::setup_wrapper() {
	local pkg_name="$1"
	local pkg_description="$2"
	local need_installation_predicate="$3"
	local installation_func="$4"
	local need_upgrade_predicate="$5"
	local upgrade_func="$6"
	local configure_func="$7"

	log::log "Setting up $pkg_name ($pkg_description)."

	# Installation
	local need_install=$($need_installation_predicate)
	if [[ "$need_install" -eq 0 ]]; then
		input::prompt_confirmation "Installing $pkg_name. Do you want to proceed?" || {
			log::info "Skipping $pkg_name setup."
			return
		}
		$installation_func
	else
		log::info "$pkg_name has already been installed."
	fi

	# Upgrade
	local need_upgrade=$($need_upgrade_predicate)
	if [[ "$need_upgrade" -eq 0 ]]; then
		# Explicitly return 0, user skipping upgrade is not an error
		input::prompt_confirmation "Upgrading $pkg_name. Do you want to proceed?" && {
			$upgrade_func
		} || return 0
	fi

	# Configuration
	$configure_func

	log::success "Finished setup for $pkg_name."
}

pkg::softlink_local_bin() {
	local binary_path="$1"
	local binary_version="$2"
	local binary_name="${3:-$(basename $binary_path)}"
	local local_bin_dir="${4:-$HOME/.local/bin}"
	local local_opt_dir="${5:-$HOME/.local/opt}"

	# Move the binary to the path
	local binary_final_dest="$local_opt_dir/$binary_name-$binary_version/$binary_name"
	mkdir -p "$(dirname "$binary_final_dest")"

	if [[ -x "$binary_final_dest" ]]; then
		log::warn "Target binary '$binary_name'-'$binary_version' already exist"
	else
		mv "$binary_path" "$binary_final_dest"
	fi

	symlink::safe_create "$binary_final_dest" "$local_bin_dir/$binary_name"
}

pkg::fetch_git_tag_release() {
	local git_repo="$1"
	local git_tag="$2"
	local bin_pattern="$3"
	local bin_name="$4"
	local timestamp=$(date '+%s')

	# Parameter expansion
	local sed_bin_pattern=$(echo "$bin_pattern" | sed "s/{{ git_tag }}/$git_tag/g")

	# Download target binary
	local temp_dir="./gittmp_$timestamp"
	mkdir $temp_dir

	# Perform in a temp dir to avoid possible name conflict
	cd "$temp_dir" && {
		log::info "Downloading $bin_name from: $git_repo/releases/download/$git_tag/$bin_pattern"

		curl -Lo "$bin_pattern" "$git_repo/releases/download/$git_tag/$bin_pattern"
		if [[ "${bin_pattern#*.}" == "tar.gz" ]]; then
			tar xf "$bin_pattern" "$bin_name"
		fi

		pkg::softlink_local_bin "$bin_name" "$git_tag"
		cd ..
	}

	# Clean up
	[[ ! -d "$temp_dir" ]] || rm -rf "$temp_dir"
}
