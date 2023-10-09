if command -v "batcat" &> /dev/null
then
    alias cat="batcat --paging=never"
elif command -v "bat" &> /dev/null
then
    alias cat="bat --paging=never"
fi

[[ ! $(command -v "explorer.exe") ]] || alias open="explorer.exe"

if command -v "eza" &> /dev/null
then
    alias ls="eza"
    alias ll="eza -alrg --icons"
else
    alias ll="ls -alrt"
fi

[[ ! $(command -v "kubectl") ]] || alias k="kubectl"

[[ ! $(command -v "terraform") ]] || alias tf="terraform"

alias sush="sudo su -"

alias src="source $HOME/.zshrc"

alias syncclock="sudo hwclock -s"

alias nv="nvim"

alias vim="nvim"

alias gg="lazygit"

alias sshconf="cat $HOME/.ssh/config"

alias gitconf="git config --list --show-origin"

alias dateunixnow="date '+%s'"

