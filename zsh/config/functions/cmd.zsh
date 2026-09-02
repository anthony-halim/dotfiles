# Fuzzy search and select on shell command history.
#
# On selection, the command will be pushed to the editing buffer stack, which allows edit
# on the command before running it. This will also allow the selected command to appear on the history
# rather than just the 'fhist'.
#
# Usage:
#   fhist
#
# Example:
#   fhist
fhist() {
	print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | sed -E 's/ *[0-9]*\*? *//' | fzf --height=40% --layout=reverse --border-label="Command History" --tac | sed -E 's/\\/\\\\/g')
}
