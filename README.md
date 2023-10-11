# 🦔 Dotfiles

![GitHub repo size](https://img.shields.io/github/repo-size/anthony-halim/dotfiles)
![GitHub commit month activity](https://img.shields.io/github/commit-activity/m/anthony-halim/dotfiles)

![image](https://github.com/anthony-halim/dotfiles/assets/50617144/b15ee4f8-27b4-4d25-972b-5b8d6a8ea323)

This repository holds my local configurations. Feel free to take ideas from it to improve your own dotfiles.

> ❗If you want to use this repository, I recommend forking this repository before usage.
> I do **unannounced breaking changes** regularly.

> This repository works best with my [Neovim Repo](https://github.com/anthony-halim/nvim) as it incorporates terminal shortcuts to trigger Neovim functionalities.  

## 🖥️ Supported OS

- WSL2 - Ubuntu 20.04, on Windows 11
- Ubuntu 22.04, Jammy LTS
- ~~Mac OS Big Sur~~ (not tested)

## ✨ Features

The functionalities that are integrated within this repository stems from my [workflows](#workflows). If any of these circumstances is similar to yours, feel free to use or adopt the idea!

#### Workflows

###### Cross platform

<details>
  <br />

  *Use case:* 
  > I work with multiple machines with varying OS. 

  *Solution:*
  > The tools need to be available on multiple platforms.
</details>

###### Support machine specific configurations 

<details>
  <br/>

  *Use case:* 
  > Different machines may need to support slightly different configuration, tools, and usage. For example, there are in-house tools shortcuts in my work machine that I do not want to be included in the repository.

  *Solution:*
  > Supports additional, uncommited, configurations and/or feature flags to influence the behaviour or its configuration. 
</details>

###### Use terminal as much as possible

<details>
  <br/>

  *Use case:* 
  > I often SSH remotely to my machine and is restricted to the terminal.

  *Solution:*
  > - Prefer TUI (Terminal UI) and CLI tools.
  > - TODO: Terminal to have a session manager to create allow working from multiple machines.
</details>

###### Provide note taking utilities that is doable everywhere

<details>
  <br/>

  *Use case:* 
  > Taking notes (for to do list and building knowledge base) is a big part of my workflow and I want to be able to do it with as little friction as possible and from any machines.

  *Solution:*
  > - Provide shortcuts for notes taking.
  > - File-based notes storage to not depend on specific application to view to avoid additional application/GUI dependencies
  > - TODO: Automatic syncing to remote storage to avoid conflicting changes.
</details>

#### Components

###### Terminal: [Wezterm](https://wezfurlong.org/wezterm/index.html) (Terminal emulator), [Zellij](https://github.com/zellij-org/zellij) (Session manager)

<details>
  <br/>

  - Due to heavy TUI usage, terminal performance becomes one of the priority. Wezterm is a cross-platform, performant terminal emulator that is able to satisfy the performance requirements and be configured easily.
  - Zellij is used to provide terminal session management and multiplexer.
</details>

###### Editor: [Neovim](neovim.io) (Text editor), [Bob](https://github.com/MordechaiHadad/bob) (Neovim version manager)

<details>
  <br/>

  - Neovim is able to be extensively configured to become a `Personal Development Environment (PDE)`, and having to not use multiple IDE for individual languages is much welcomed.
  - The complete configuration and set-up are done on a separate repository; check my [Neovim Repo](https://github.com/anthony-halim/nvim).
</details>

###### Shell: [ZSH](https://en.wikipedia.org/wiki/Z_shell) (Shell), [powerlevel10k](https://github.com/romkatv/powerlevel10k) (theme)

<details>
  <br/>

- ZSH is battle tested shell that is easily configurable and is widely supported. Note that I do not use an plugin manager (at least for now). *I am* the plugin manager.
- powerlevel10k as performant shell theme. 
</details>

###### Shell highlighter and utilities: [eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat), [lazygit](https://github.com/jesseduffield/lazygit), [delta](https://github.com/dandavison/delta), [fzf](https://github.com/junegunn/fzf), [fd](https://github.com/sharkdp/fd), [ripgrep](https://github.com/BurntSushi/ripgrep) 

<details>
  <br/>

  - `eza` as better `ls`. Aliased to `ls`.
  - `bat` as better `cat`. Aliased to `cat`.
  - `lazygit` as simple Git terminal UI.
  - `delta` as syntax highlighter for Git.
  - `fzf`, `fd`, `ripgrep` as search utilities.
</details>

<details>
  <summary>Showcase</summary>

  *eza* 
  ![credit to source repository](https://github.com/eza-community/eza/blob/main/screenshots.png) 

  *bat (credit to source repository)* 
  ![credit to source repository](https://camo.githubusercontent.com/7b7c397acc5b91b4c4cf7756015185fe3c5f700f70d256a212de51294a0cf673/68747470733a2f2f696d6775722e636f6d2f724773646e44652e706e67)
  *lazygit*
  ![credit to source repository](https://github.com/jesseduffield/lazygit/blob/assets/demo/commit_and_push-compressed.gif)

  *delta*
  ![credit to source repository](https://user-images.githubusercontent.com/50617144/266825290-21025bbd-89c4-4ff7-ba81-81a273604632.png)

</details>

###### Programming languages and utilities

<details>
  <br/>

  - Programming languages and their utility tools that I often use e.g. [Golang](https://go.dev/), [pyenv](https://github.com/pyenv/pyenv) are installed by default.
</details>


#### Highlighted (common) commands output

TODO

#### Zettelkasten notes taking utilities

TODO

## Environment Variables

Below are environment variables that can be set freely to configure the behaviour.

| Environment Variable Name | Description    | Behaviour    |
| ------------------------- | -------------- | ------------ |
| Item1.1    | Item2.1    | Item3.1    |

> HINT: You can set these 
TODO

## 🖥️ Supported OS

- WSL2 - Ubuntu 20.04, on Windows 11
- Ubuntu 22.04, Jammy LTS
- ~~Mac OS Big Sur~~ (deprecated)

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

Whitelist the private key by adding the public key from SSH keys generated to your Git user.

##### WezTerm

Visit [Wezterm's Download](https://wezfurlong.org/wezterm/installation.html) page and follow the installation steps.

## 🌱  Usage

##### Git clone this repository to `$HOME/repos/personal/`

My personal convention is to store repositories based on their use cases.

- `$HOME/repos/personal` to hold personal repositories.
- `$HOME/repos/work` to hold work-related repositories.

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

The default key bindings are not the most ergonomic for programmers, and we can perform some key swaps to help make it better. Your hands will thank you! 

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

I have prepared a script that automates the rest of the configuration. The script has **tons** of user confirmation; (i) partly to ensure that the user knows what is happening and (ii) partly to allow the user to skip specific configurations.

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

