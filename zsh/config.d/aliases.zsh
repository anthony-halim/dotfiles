if command -v "batcat" &> /dev/null
then
    alias cat="batcat --paging=never $1"
elif command -v "bat" &> /dev/null
then
    alias cat="bat --paging=never $1"
fi

if command -v "explorer.exe" &> /dev/null
then
    alias open="explorer.exe $1"
fi

if command -v "exa" &> /dev/null
then
    alias ls="exa"
    alias lsd="exa -alrg"
else
    alias lsd="ls -alrt"
fi

alias sush="sudo su -"

alias src="source $HOME/.zshrc"

alias syncclock="sudo hwclock -s"

alias vim="nvim"

alias vi="nvim"

alias rp="cd $HOME/repos"

alias lg="lazygit"

alias sshconfig="cat $HOME/.ssh/config"

alias gitconfig="git config --list --show-origin"

alias dateunixnow="date '+%s'"

