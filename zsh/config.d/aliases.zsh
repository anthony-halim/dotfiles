
if command -v "explorer.exe" &> /dev/null
then
    alias open="explorer.exe $1"
fi

alias sush="sudo su -"

alias src="source $HOME/.zshrc"

alias syncclock="sudo hwclock -s"

alias vim="nvim"

alias vi="nvim"

alias lsd="ls -alrt"

alias repodir="cd $HOME/repos"

alias lg="lazygit"

alias sshconfig="cat $HOME/.ssh/config"

alias gitconfig="git config --list --show-origin"

alias dateunixnow="date '+%s'"

