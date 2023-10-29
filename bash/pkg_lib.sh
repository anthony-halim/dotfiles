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
	local local_bin_dir="${3:-$HOME/.local/bin}"

	local binary_name="$(basename $binary_path)"
	local local_opt_dir="$HOME/.local/opt"

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

# Git package manager
# Checks latest release tag upstream and update the package if required
pkg::manage_by_git_release() {
	local pkg_name="$1"
	local pkg_description="$2"
	local pkg_install_predicate_func="$3"
	local pkg_configure_func="$4"
	local pkg_current_tag_func="$5"
	local git_repo="$6"
	local git_tag="$7"
	local git_tag_pattern="$8"
	local git_bin_pattern="$9"
	local git_bin_name="${10}"
	local git_bin_dest="${11:-$HOME/.local/bin}"

	local fresh_install=false
	local timestamp=$(date '+%s')

	# Parameter expansion
	if [[ "$git_tag" == "latest" ]]; then
		git_tag=$(git::fetch_latest_tag "$git_repo" "$git_tag_pattern")
		log::info "Translated $pkg_name: 'latest' to '$git_tag'"
	fi
	local truncated_git_tag=$(parser::extract_semver "$git_tag")
	git_bin_pattern=$(echo "$git_bin_pattern" | sed "s/{{ git_tag }}/$git_tag/g")
	git_bin_pattern=$(echo "$git_bin_pattern" | sed "s/{{ truncated_git_tag }}/$truncated_git_tag/g")

	# Installation
	install_predicate_func() {
		local need_install=$($pkg_install_predicate_func)
		echo "$need_install"
	}
	install_func() {
		local git_bin_url="$git_repo/releases/download/$git_tag/$git_bin_pattern"
		local temp_dir="./gitrlsm_$timestamp"
		mkdir $temp_dir

		# Perform in a temp dir to avoid name conflict
		cd "$temp_dir" && {
			log::info "Downloading $pkg_name from: $git_bin_url"

			curl -Lo "$git_bin_pattern" "$git_bin_url"

			# Only extract if extension is tar.gz
			if [[ $git_bin_pattern == *.tar.gz ]]; then
				tar xf "$git_bin_pattern"
			fi

			# Link the binary to the destination
			pkg::softlink_local_bin "$git_bin_name" "$git_tag" "$git_bin_dest"

			cd ..
		}

		# Clean up
		[[ ! -d "$temp_dir" ]] || rm -rf "$temp_dir"

		# Mark that this is freshly installed
		fresh_install=true
	}

	# Upgrade
	need_upgrade_predicate() {
		if [[ $fresh_install == true ]]; then
			# Skip upgrade if we just installed
			echo 1
			return
		fi

		local pkg_current_tag=$($pkg_current_tag_func)
		local truncated_pkg_current_tag=$(parser::extract_semver "$pkg_current_tag")

		# Upgrade if current version is different from target tag
		if [[ "$truncated_pkg_current_tag" != "$truncated_git_tag" ]]; then
			log::warn "Attempting to upgrade $pkg_name version from '$truncated_pkg_current_tag' to '$truncated_git_tag'"
			echo 0
		else
			echo 1
		fi
	}
	upgrade_func() {
		install_func
	}

	# Configuration
	configure_func() {
		$pkg_configure_func
	}

	pkg::setup_wrapper "$pkg_name" "$pkg_description" install_predicate_func install_func need_upgrade_predicate upgrade_func configure_func
}
