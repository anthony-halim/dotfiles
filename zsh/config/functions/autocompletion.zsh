# Enable auto completion for tools
[[ ! $(command -v terraform) ]] || complete -o nospace -C $(which terraform) terraform
[[ ! $(command -v kubectl) ]] || source <(kubectl completion zsh) 
[[ ! $(command -v minikube) ]] || source <(minikube completion zsh) 
