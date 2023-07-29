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
ssh-keygen
```

Whitelist the private key by adding the public key from SSH keys generated to your Git user.

#### Install Rust (Optional)

Install rust if you will be using it. Visit [Rust installation](https://www.rust-lang.org/tools/install). For most cases, it will be by executing the following command and following the interactive configuration.

```shell
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

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

- Configure passwordless sudo for the user that is executing the script, can be disabled by supplying *--disable_pwless_sudo*.
- Install dependencies.
- Install Python, with pyenv and setup python version globally to *--python_version*. Defaults to 3.8.5.
- Install NeoVim, with tags equal to *--neovim_tag*. Defaults to latest.
- Install ZSH, with OMZ as package manager, as default terminal.
- Configure ZSH configuration.
- Configure Git configuration.
- COnfigure NeoVim configuration.
- Configure Wezterm configuration.

> NOTE: For Windows, please create a symbolic link for **wezterm.lua** from the Wezterm installation directory to the Wezterm configuration.
> ```Powershell
> # Given installation dir: "C:\Program Files\Wezterm"
> # Given local repository configuration: "\\wsl.localhost\Ubuntu\home\anthonyhalim\repos\personal\dotfiles"
> New-Item -Path "C:\Program Files\WezTerm\wezterm.lua" -ItemType SymbolicLink -Value "\\wsl.localhost\Ubuntu\home\anthonyhalim\repos\personal\dotfiles\wezterm\wezterm-wsl.lua"
> ```

You may refer to *setup.sh -h* to see the full range of options.


