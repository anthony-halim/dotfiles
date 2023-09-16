if command -v "batcat" &> /dev/null
then
    alias cat="batcat --paging=never"
elif command -v "bat" &> /dev/null
then
    alias cat="bat --paging=never"
fi

if command -v "explorer.exe" &> /dev/null
then
    alias open="explorer.exe $1"
fi

if command -v "eza" &> /dev/null
then
    alias ls="eza"
    alias ll="eza -alrg --icons"
else
    alias ll="ls -alrt"
fi

if command -v "kubectl" &> /dev/null
then
  alias k="kubectl"
fi

if command -v "terraform" &> /dev/null
then
  alias t="terraform"
fi

alias sush="sudo su -"

alias src="source $HOME/.zshrc"

alias syncclock="sudo hwclock -s"

alias nv="nvim"

alias vim="nvim"

alias cdrepos="cd $HOME/repos"

alias cdnotes="cd $HOME/notes"

alias gg="lazygit"

alias sshconf="cat $HOME/.ssh/config"

alias gitconf="git config --list --show-origin"

alias dateunixnow="date '+%s'"

