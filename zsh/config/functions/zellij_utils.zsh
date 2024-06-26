# Auto rename zellij tab if in Git repository
zellij_tab_name_update_by_git_repo() {
	if [[ -n $ZELLIJ ]]; then
		tab_name=''
		if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
			tab_name+=$(basename "$(git rev-parse --show-toplevel)")
			tab_name="git - ${tab_name%/}"
		else
			tab_name=$PWD
			if [[ $tab_name == $HOME ]]; then
				tab_name="~"
			else
				tab_name=${tab_name##*/}
			fi
		fi
		command nohup zellij action rename-tab "$tab_name" >/dev/null 2>&1
	fi
}

zellij_autostart() {
	if [[ $(command -v zellij) && "$ZELLIJ_AUTO_START" = true ]]; then
		# From 'eval "$(zellij setup --generate-auto-start zsh)"'
		if [[ -z "$ZELLIJ" ]]; then
			if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
				zellij attach -c
			else
				zellij
			fi
		fi
	fi
}
