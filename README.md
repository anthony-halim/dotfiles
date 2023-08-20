# Dotfiles

This repository holds my local configurations. Currently supports *WSL2 - Ubuntu-20.04, on Windows 11* and *MacOS Big Sur*.

## Prerequisites

#### Windows: WSL Setup 

Run Powershell as administrator & install Ubuntu distribution.

```sh
wsl --install -d Ubuntu
# For Ubuntu 20.04, do wsl --install -d Ubuntu-20.04
```

Setup user.

#### (Recommended) Swap Keys 

The default key bindings are not the most ergonomic for programmers, and we can perform some key swappings to help make it better.

Your hand will thank you! 

> NOTE: There are lots of third party software that aids key swapping to an extensive degree of customisation (for example, [Karabiner](https://github.com/pqrs-org/Karabiner-Elements) for MacOS, [xcape](https://github.com/alols/xcape) for Linux). However, you may not want (or allowed) to install third party software that customise close to the firmware level. 
> Due to this, we opt to use built-in or officially supported by the OS itself, albeit it support less extensive customisation.
>
> If you are using this, an idea for customisation is:
> - On `Caps Lock` tap, map it as `Esc`. On `Caps Lock` hold, map it as `Ctrl`.

##### Windows: Swap `Esc` and `Caps Lock` 

For Windows, you can install PowerToys, through the Keyboard Manager.

```Powershell
winget install Microsoft.PowerToys --source winget
```

Perform the swap between `Esc` and `Caps Lock` by adding two entries:
- `Esc` to `Caps Lock`
- `Caps Lock` to `Esc`  

##### MacOS: Map `Caps Lock` to `Esc` and `fn` to `Ctrl`    

Newer MacOS has native support for mapping keyboard modifier keys.

Go to *System Preferences* &rarr; *Keyboard* &rarr; *Modifier Keys*:
- `Caps Lock` to `Esc`
- `fn` to `Control`

> NOTE: Yes, we are losing `Caps Lock` and `fn` buttons with this mapping. If you find yourself using these keys often, this is not for you. 

#### WezTerm

Visit [Wezterm's Download](https://wezfurlong.org/wezterm/installation.html) page to and follow the installation steps.

#### Git SSH Keys

We need to allow SSH authentication in order to do git operations with Git repositories.

```sh
# Generate fresh SSH keys
ssh-keygen -t rsa
```

Whitelist the private key by adding the public key from SSH keys generated to your Git user.

#### Clone this repository to $HOME/repos/personal/

For convention sake, all repositories will be stored under $HOME/repos.

- $HOME/repos/personal to hold personal repositories.
- $HOME/repos/work to hold work related repositories.

```sh
mkdir -p $HOME/repos/personal 
mkdir -p $HOME/repos/work 
```

## Usage

The remaining configuration will be automatically setup by *setup.sh*. It will perform the following:

- Install dependencies.
- Install Pyenv as Python version manager.
- Install Golang, with version equal to *--golang_tag*, defaults to 1.21.0.
- Install Rust 
- Install NeoVim, with tags equal to *--neovim_tag*. Defaults to 0.9.1.
- Install ZSH, with OMZ as package manager, as default terminal.
- Configure ZSH configuration.
- Configure Git configuration.
- Configure Wezterm configuration.

> NOTE: Post pyenv installation, shell integration requires the following snippet in your shell profile:
> ```sh
> # For example, in .zshrc
> export PYENV_ROOT="$HOME/.pyenv"
> command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
> eval "$(pyenv init -)>"
> ```
> This snippet is already included if you proceed with the repository's ZSH installation and configuration. Please include it in your shell profile if you do not choose to do so!

> NOTE: For Linux, post Golang installation, shell integration requires the following snippet in your shell profile:
> ```sh
> # For example, in .zshrc
> export PATH=$PATH:/usr/local/go/bin
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
