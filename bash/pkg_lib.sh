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
	local need_install
	need_install=$($need_installation_predicate)
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
	local need_upgrade
	need_upgrade=$($need_upgrade_predicate)
	if [[ "$need_upgrade" -eq 0 ]]; then
		# Explicitly return 0, user skipping upgrade is not an error
		input::prompt_confirmation "Upgrading $pkg_name. Do you want to proceed?" && {
			$upgrade_func
		} || return 0
	fi

	# Configuration
	log::info "Configuring $pkg_name."
	$configure_func

	log::success "Finished setup for $pkg_name."
}

# Git package manager that manages based on release binary
# Checks latest release tag upstream and update the package if required
pkg::manage_by_git_release_bin() {
	local pkg_name="$1"                   # Package name to be installed, used for logging
	local pkg_description="$2"            # Description of the package, used for logging
	local pkg_install_predicate_func="$3" # Function to dictate whether we should proceed with installation
	local pkg_configure_func="$4"         # Post installation/update function for the package
	local pkg_current_tag_func="$5"       # Function that outputs the current version of the package
	local git_repo="$6"                   # URL of the git repository
	local git_tag="$7"                    # Target git tag to be installed. If set to 'latest', we will fetch from git repo
	local git_tag_pattern="$8"            # Tag pattern in the repository
	local git_bin_pattern="$9"            # Binary/tar.gz to be downloaded from the tag release
	local git_bin_path="${10}"            # Path to the binary in the downloaded binary/tar.gz

	local local_bin_name
	local_bin_name="$(basename "$git_bin_path")"
	local local_bin="${11:-$HOME/.local/bin/$local_bin_name}" # Where the binary should be symlinked to

	local timestamp
	timestamp=$(date '+%s')

	# Handle git tag
	if [[ "$git_tag" == "latest" ]]; then
		git_tag=$(git::fetch_latest_tag "$git_repo" "$git_tag_pattern")
		log::info "Translated $pkg_name: 'latest' to '$git_tag'"
	fi

	# Handle git binary pattern
	local truncated_git_tag
	truncated_git_tag=$(parser::extract_semver "$git_tag")
	git_bin_pattern=$(echo "$git_bin_pattern" | sed "s/{{ git_tag }}/$git_tag/g")
	git_bin_pattern=$(echo "$git_bin_pattern" | sed "s/{{ truncated_git_tag }}/$truncated_git_tag/g")
	git_bin_path=$(echo "$git_bin_path" | sed "s/{{ git_tag }}/$git_tag/g")
	git_bin_path=$(echo "$git_bin_path" | sed "s/{{ truncated_git_tag }}/$truncated_git_tag/g")

	# Handle local paths
	local local_bin_name
	local_bin_name="$(basename "$git_bin_path")"
	local local_opt_dir="$HOME/.local/opt"
	local local_opt_bin_dir_non_ver="$local_opt_dir/$local_bin_name"
	local local_opt_bin_dir="$local_opt_bin_dir_non_ver-$git_tag"
	local local_opt_bin="$local_opt_bin_dir/$git_bin_path"

	# Installation
	install_predicate_func() {
		local need_install
		need_install=$($pkg_install_predicate_func)
		echo "$need_install"
	}
	install_func() {
		# Fast return if it is already installed
		if [[ -x "$local_opt_bin" ]]; then
			log::info "$pkg_name $git_tag has already been installed!"
			return
		fi

		local git_bin_url="$git_repo/releases/download/$git_tag/$git_bin_pattern"
		local temp_dir="./gitrlsm_$timestamp"
		mkdir "$temp_dir"

		# Perform in a temp dir to avoid name conflict
		cd "$temp_dir" && {
			log::info "Downloading $pkg_name from: $git_bin_url"

			curl -Lo "$git_bin_pattern" "$git_bin_url"

			# Only extract if extension is tar.gz
			if [[ $git_bin_pattern == *.tar.gz ]]; then
				tar xf "$git_bin_pattern"
				rm "$git_bin_pattern"
			fi

			# Move downloaded package to the local directory
			mkdir -p "$local_opt_bin_dir"
			mv ./* "$local_opt_bin_dir/"

			cd ..
		}

		# Clean up
		[[ ! -d "$temp_dir" ]] || rm -rf "$temp_dir"

		# Link the binary to the destination
		symlink::safe_create "$local_opt_bin" "$local_bin"
	}

	# Upgrade
	need_upgrade_predicate() {
		local pkg_current_tag
		local truncated_pkg_current_tag
		pkg_current_tag=$($pkg_current_tag_func)
		truncated_pkg_current_tag=$(parser::extract_semver "$pkg_current_tag")

		# Upgrade if current version is different from target tag
		if [[ "$truncated_pkg_current_tag" != "$truncated_git_tag" ]]; then
			log::warn "Attempting to upgrade $pkg_name version from '$truncated_pkg_current_tag' to '$truncated_git_tag'"
			echo 0
		else
			echo 1
		fi
	}
	upgrade_func() {
		# If existing symlink is to another binary with the same folder pattern, that is
		# managed by this function. Remove it first.
		if [[ -L "${local_bin}" ]]; then
			local actual_bin=$(readlink -n "${local_bin}")
			local actual_bin_dir=$(dirname "${actual_bin}")

			if [[ "${actual_bin_dir}" =~ $local_opt_bin_dir_non_ver ]]; then
				log::info "Removing old link of $pkg_name the previous release"
				rm "${local_bin}"
			fi
		fi

		# Finally, perform re-installation
		install_func
	}

	# Configuration
	configure_func() {
		# Configure based on user func
		$pkg_configure_func
	}

	pkg::setup_wrapper "$pkg_name" "$pkg_description" install_predicate_func install_func need_upgrade_predicate upgrade_func configure_func
}
