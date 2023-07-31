# Dotfiles

This repository holds my local configurations.

## Prerequisites

#### Windows: WSL Setup 

Run Powershell as administrator & install Ubuntu distribution.

```shell
wsl --install -d Ubuntu
# For Ubuntu 20.04, do wsl --install -d Ubuntu-20.04
```

#### WezTerm

Visit [Wezterm's Download](https://wezfurlong.org/wezterm/installation.html) page to and follow the installation steps.

Setup user.

#### Git SSH Keys

We need to allow SSH authentication in order to do git operations with Git repositories.

```shell
# Generate fresh SSH keys
ssh-keygen -t rsa
```

Whitelist the private key by adding the public key from SSH keys generated to your Git user.

#### Clone this repository to $HOME/repos/personal/

For convention sake, all repositories will be stored under $HOME/repos.

- $HOME/repos/personal to hold personal repositories.
- $HOME/repos/work to hold work related repositories.

```shell
mkdir -p $HOME/repos/personal 
mkdir -p $HOME/repos/work 
```

## Usage

The remaining configuration will be automatically setup by *setup.sh*. It will perform the following:

- Install dependencies.
- Install pyenv as Python version manager.
- Install rust
- Install NeoVim, with tags equal to *--neovim_tag*. Defaults to v0.9.1.
- Install ZSH, with OMZ as package manager, as default terminal.
- Configure ZSH configuration.
- Configure Git configuration.
- Configure Wezterm configuration.

> NOTE: Post pyenv installation, shell integration requires the following snippet in your shell profile:
> ```shell
> # For example, in .zshrc
> export PYENV_ROOT="$HOME/.pyenv"
> command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
> eval "$(pyenv init -)>"
> ```
> This snippet is already included if you proceed with the repository's ZSH installation and configuration. Please include it in your shell profile if you do not choose to do so!

> NOTE: For Windows, please create a symbolic link for **wezterm.lua** from the Wezterm installation directory to the Wezterm configuration. Below is sample command for Powershell.
> ```Powershell
> # Given installation dir: "C:\Program Files\Wezterm"
> # Given local repository configuration: "\\wsl.localhost\Ubuntu\home\anthonyhalim\repos\personal\dotfiles"
> New-Item -Path "C:\Program Files\WezTerm\wezterm.lua" -ItemType SymbolicLink -Value "\\wsl.localhost\Ubuntu\home\anthonyhalim\repos\personal\dotfiles\wezterm\wezterm-wsl.lua"
> ```

You may refer to *setup.sh -h* to see the full range of options.

For NeoVim configuration setup, please setup separately as per directed in the [Nvim Repo](https://github.com/anthony-halim/nvim).
