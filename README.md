# 🦔 Dotfiles

![GitHub repo size](https://img.shields.io/github/repo-size/anthony-halim/dotfiles)
![GitHub commit month activity](https://img.shields.io/github/commit-activity/m/anthony-halim/dotfiles)

![image](https://github.com/anthony-halim/dotfiles/assets/50617144/b15ee4f8-27b4-4d25-972b-5b8d6a8ea323)

This repository holds my local configurations.

> ❗If you want to use this repository, I recommend forking this repository before usage.
> I do **unannounced breaking changes** regularly.

## 🖥️ Supported OS

- WSL2 - Ubuntu 20.04, on Windows 11
- MacOS Big Sur

## 🧱 Components

- [Wezterm](https://wezfurlong.org/wezterm/index.html) as the terminal emulator, with additional configurations and key bindings.
- [ZSH](https://en.wikipedia.org/wiki/Z_shell) as default terminal and custom configurations and aliases. I don't install any plugin manager for ZSH. *I am* the plugin manager.
- [powerlevel10k](https://github.com/romkatv/powerlevel10k) as ZSH theme.
- [lazygit](https://github.com/jesseduffield/lazygit) as simple Git terminal UI.
- [Neovim](neovim.io) as text editor. The complete configuration and set-up are done on a separate repository; check my [Neovim Repo](https://github.com/anthony-halim/nvim).
- Programming languages and their utility tools that I often use e.g. [Golang](https://go.dev/), [pyenv](https://github.com/pyenv/pyenv)

## 📋 Prerequisites

The following prerequisites are not automatically set up and must be done manually.

##### Windows: WSL Installation 

Run Powershell as administrator & install Ubuntu distribution.

```sh
wsl --install -d Ubuntu
# For Ubuntu 20.04, do wsl --install -d Ubuntu-20.04
```

##### Git SSH Keys

We need to allow SSH authentication to do Git operations with Git repositories.

```sh
# Generate fresh SSH keys
ssh-keygen -t rsa
```

White-list the private key by adding the public key from SSH keys generated to your Git user.

##### WezTerm

Visit [Wezterm's Download](https://wezfurlong.org/wezterm/installation.html) page and follow the installation steps.

## 🌱  Usage

##### Git clone this repository to $HOME/repos/personal/

My personal convention is to store repositories based on their use cases.

- $HOME/repos/personal to hold personal repositories.
- $HOME/repos/work to hold work-related repositories.

```sh
mkdir -p $HOME/repos/personal 
mkdir -p $HOME/repos/work 
```

We use Git submodules within this repository. To git clone with the submodules,

```sh
git clone --recurse-submodules --shallow-submodules https://github.com/anthony-halim/dotfiles.git $HOME/repos/personal/dotfiles
```

> NOTE: If the repository is already cloned without submodules, you can fetch the submodules by:
> ```sh
> git submodule init
> git submodule update --depth=1
> ```

##### Run *setup.sh*

Refer to [Setup](#setup) for details.

##### (Optional) Add custom local configurations at `$HOME/.config/zsh/local_config` directory

Any `*.zsh` file at `$HOME/.config/zsh/local_config` will be automaticaly loaded during ZSH initialisation. These files **will not** be committed to the repository.

I use this to store machine-specific configurations, functions, or aliases. For example, my work machine would have VPN shortcuts which I do not want to committed to this repository.

##### (Optional) Swap Keys 

The default key bindings are not the most ergonomic for programmers, and we can perform some key swaps to help make it better. Your hand will thank you! 

<details>
  <summary>Windows</summary>
  <br />

  You can install PowerToys, and configure the mapping through the Keyboard Manager.

  ```Powershell
  winget install Microsoft.PowerToys --source winget
  ```

  Perform the swap between `Esc` and `Caps Lock` by adding two entries:
  - `Esc` to `Caps Lock`
  - `Caps Lock` to `Esc`  

</details>

<details>
  <summary>MacOS</summary>
  <br />

  Newer MacOS has native support for mapping keyboard modifier keys.

  Go to *System Preferences* &rarr; *Keyboard* &rarr; *Modifier Keys*:
  - `Caps Lock` to `Esc`
  - `fn` to `Control`

  > NOTE: Yes, we are losing the `Caps Lock` and `fn` buttons with this mapping. If you use these keys often, this is not for you. 

</details>

## ⚙️ Setup

```sh
./setup.sh [-h] [-v] [--git_user git_user] [--git_user_email git_user_email] [--git_user_local_file path_to_file] 
                     [--golang_tag golang_semver] [--golang_sys system_type]
                     [--neovim_tag neovim_semver]
```

I have prepared a script that automates the rest of the configuration. The script has **tons** of user confirmation; (i) partly to ensure that the user knows what happening and (ii) partly to allow the user to skip specific configurations.

*Feel free to run the setup script for fun and skip all configurations to see what would be configured.*

I have done my best to ensure that the script is:
- **Idempotent** i.e. able to be run multiple times without any side effects.
- **Backs up** any existing configuration if a replacement needs to be made.

> NOTE: Many dependencies require some sort of shell integration script; these are already integrated within the ZSH configurations. See [exports.zsh](zsh/config/exports.zsh). If you decide to skip using this repository ZSH configurations, please remember to integrate the dependencies.

> NOTE: For Windows, please create a symbolic link for **wezterm.lua** from the Wezterm installation directory to the Wezterm configuration. Below is a sample command for Powershell.
> ```Powershell
> # Given installation dir: "C:\Program Files\Wezterm"
> # Given local repository configuration: "\\wsl.localhost\Ubuntu\home\anthonyhalim\repos\personal\dotfiles"
> New-Item -Path "C:\Program Files\WezTerm\wezterm.lua" -ItemType SymbolicLink -Value "\\wsl.localhost\Ubuntu\home\anthonyhalim\repos\personal\dotfiles\wezterm\wezterm-wsl.lua"
> ```

Below is a screenshot of a snippet of the script run:
  
![image](https://github.com/anthony-halim/dotfiles/assets/50617144/2ed8a968-4f67-4555-a6f6-6838503c5229)

## 🤔 FAQ

**Q: Why not use third-party keyboard managers?** 

> There are lots of third-party software that aids key swapping to an extensive degree of customisation (for example, [Karabiner](https://github.com/pqrs-org/Karabiner-Elements) for MacOS, [xcape](https://github.com/alols/xcape) for Linux). However, you may not want (or be allowed) to install third-party software that customises close to the firmware level. 
>
> Due to this, I opt to use built-in or officially supported by the OS, albeit it supports less extensive customisation.
>
> If you are using third-party software, an idea for customisation is:
> - On `Caps Lock` tap, map it as `Esc`. 
> - On `Caps Lock` hold, map it as `Ctrl`.

**Q: No tmux?**

> I have not found the use case for tmux; Wezterm currently fulfils all my tick boxes.
