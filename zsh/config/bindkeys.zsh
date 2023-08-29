# sudo plugin: [Esc] [Esc]
bindkey -M emacs '\e\e' sudo-command-line
bindkey -M vicmd '\e\e' sudo-command-line
bindkey -M viins '\e\e' sudo-command-line

# zsh-history-substring-search plugin: Arrow Up/Down 
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
