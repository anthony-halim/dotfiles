# Enable auto completion for tools
[[ ! $(command -v kubectl) ]] || source <(kubectl completion zsh)
