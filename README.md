# 🦔 Dotfiles

![GitHub repo size](https://img.shields.io/github/repo-size/anthony-halim/dotfiles)
![GitHub commit month activity](https://img.shields.io/github/commit-activity/m/anthony-halim/dotfiles)

![image](https://github.com/anthony-halim/dotfiles/assets/50617144/b15ee4f8-27b4-4d25-972b-5b8d6a8ea323)

This repository holds my local configurations. Feel free to take ideas from it to improve your own dotfiles.

> ❗If you want to use this repository, I recommend forking this repository before usage.
> I do **unannounced breaking changes** regularly.

> This repository works best with my [Neovim Repo](https://github.com/anthony-halim/nvim) as it incorporates terminal shortcuts to trigger Neovim functionalities.  

---

## 🖥️ Supported OS

- WSL2 - Ubuntu 20.04, on Windows 11
- Ubuntu 22.04, Jammy LTS
- ~~Mac OS Big Sur~~ (not tested)

---

## ✨ Features

The features integrated within this repository stems from my workflows. 

#### Allows for machine specific configurations

My workflows use different machines with slightly different configuration, tools, and usage. For example, my work machine has VPN shortcuts which I do not want to commit to this repository.

There are 2 ways custom configuration can be made:

- Adding [custom local configs](#optional-add-custom-local-configurations-at-homeconfigzshlocal_config-directory).
- Set [environment variables](#environment-variables).

#### Budget version of [z](https://github.com/rupa/z) for directory traverse: `bm` and `goto`

For those have not checked out [z](https://github.com/rupa/z), I recommend trying it out for fast travels between directories. This repository provides a *budget version* of `z`, powered by [fzf](https://github.com/junegunn/fzf): `bm (bookmark)` and `goto`.

- `bm` bookmarks the current directory.
- `goto` fast travels to the directory e.g. `goto foo`, where `foo` is a fuzzy match to the full path.
- On name conflict, `fzf` window will be spawned.

#### Notes Taking

This repository provides shortcuts to enable [Zettlekasten](https://zettelkasten.de/posts/overview/) style of note taking. It depends on Neovim and [telekasten.nvim](https://github.com/renerocksai/telekasten.nvim) plugin.

- Notes are markdown file based. This avoids additional GUI or application to view the notes.
- The followings shortcuts are provided to increase ease of use:

  <details>
    <summary>Shortcuts</summary>
    <br/>

    - `ndaily` opens daily note (create if does not exist).
    - `nweekly` opens weekly note (create if does not exist).
    - `nfind` find notes by title
    - `ngrep` find notes by content grep
    - `ntags` find notes by tags
    - `nnew` create new notes
    - `ntmplnew` create new templated note
    - `ncommit` commits note repository to upstream branch
    - `npull` pull latest changes of note repository from upstream branch
  </details>

  For more information and usage, see [functions.zsh](zsh/config/functions.zsh).

---

## 🧱 Components

#### Terminal: [Wezterm](https://wezfurlong.org/wezterm/index.html) (Terminal emulator), [Zellij](https://github.com/zellij-org/zellij) (Session manager), [ZSH](https://en.wikipedia.org/wiki/Z_shell) (Shell), [powerlevel10k](https://github.com/romkatv/powerlevel10k) (theme)

<details>
  <br/>

  - Due to heavy TUI usage, terminal performance becomes one of the priority. Wezterm is a cross-platform, performant terminal emulator that is able to satisfy the performance requirements and be configured easily.
  - Zellij is used to provide terminal session management and multiplexer.
  - ZSH is battle tested shell that is easily configurable and is widely supported. Note that I do not use an plugin manager (at least for now). *I am* the plugin manager.
  - powerlevel10k as performant shell theme. 
</details>

<details>
  <summary>Showcase</summary>
  <br/>

  ![image](https://github.com/anthony-halim/dotfiles/assets/50617144/b15ee4f8-27b4-4d25-972b-5b8d6a8ea323)
</details>

#### Shell highlighter and utilities: [eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat), [lazygit](https://github.com/jesseduffield/lazygit), [delta](https://github.com/dandavison/delta), [fzf](https://github.com/junegunn/fzf), [fd](https://github.com/sharkdp/fd), [ripgrep](https://github.com/BurntSushi/ripgrep) 

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
  <br/>

  *eza* 

  ![credit to source repository](https://github.com/eza-community/eza/blob/main/screenshots.png) 

  *bat* 

  ![credit to source repository](https://camo.githubusercontent.com/7b7c397acc5b91b4c4cf7756015185fe3c5f700f70d256a212de51294a0cf673/68747470733a2f2f696d6775722e636f6d2f724773646e44652e706e67)

  *lazygit*

  ![credit to source repository](https://github.com/jesseduffield/lazygit/blob/assets/demo/commit_and_push-compressed.gif)

  *delta*

  ![credit to source repository](https://user-images.githubusercontent.com/50617144/266825290-21025bbd-89c4-4ff7-ba81-81a273604632.png)

</details>

#### Editor: [Neovim](neovim.io) (Text editor), [Bob](https://github.com/MordechaiHadad/bob) (Neovim version manager)

<details>
  <br/>

  - Neovim is able to be extensively configured to become a `Personal Development Environment (PDE)`, and having to not use multiple IDE for individual languages is much welcomed.
  - The complete configuration and set-up are done on a separate repository; check my [Neovim Repo](https://github.com/anthony-halim/nvim).
</details>

<details>
  <summary>Showcase</summary>
  <br/>

  ![img](https://user-images.githubusercontent.com/50617144/274354764-2c92be00-09c7-4573-8098-b170b832e0b0.png) 
</details>

#### Programming languages and utilities: Golang, Python, Rust

<details>
  <br/>

  - Programming languages and their utility tools that I often use e.g. [Golang](https://go.dev/), [pyenv](https://github.com/pyenv/pyenv) are installed by default.
</details>

---

## 🌱  Usage

#### Git clone this repository

We use Git submodules within this repository. To git clone with the submodules,

```sh
git clone --recurse-submodules --shallow-submodules https://github.com/anthony-halim/dotfiles.git 
```

> NOTE: If the repository is already cloned without submodules, you can fetch the submodules by:
> ```sh
> git submodule init
> git submodule update --depth=1
> ```

#### Windows: WSL Installation 

Run Powershell as administrator & install Ubuntu distribution.

```sh
wsl --install -d Ubuntu
# For Ubuntu 20.04, do wsl --install -d Ubuntu-20.04
```
#### Install WezTerm

Visit [Wezterm's Download](https://wezfurlong.org/wezterm/installation.html) page and follow the installation steps.

#### Run *setup.sh*

Refer to [Setup](#setup) for details.

#### (Optional) Add custom local configurations at `$HOME/.config/zsh/local_config` directory

Any `*.zsh` file at `$HOME/.config/zsh/local_config` will be automaticaly loaded during ZSH initialisation. These files **will not** be committed to the repository. 

You can use this to add additional aliases, environment variables, or functions.

#### (Optional) Set environment variables

The following environment variables affects the repository behaviour. You can set it by exporting the variable in a custom `.zsh` file. See [adding custom configuration](#optional-add-custom-local-configurations-at-homeconfigzshlocal_config-directory).

**Notes** 

| Name                   | Type                   | Defaults                 | Description     |
|----------------------- | ---------------------- | ------------------------ | --------------- |
| NOTES_DEFAULT_VAULT    | "personal"\|"work"     | "personal"               | Default vault (notes directory) to be used on load. |
| NOTES_WORK_VAULT       | string                 | "$HOME/notes/work"       | Path to work notes vault (notes directory).         |
| NOTES_PERSONAL_VAULT   | string                 | "$HOME/notes/personal"   | Path to personal notes vault (notes directory)      |

**ZSH** 

| Name                   | Type                   | Defaults                       | Description     |
|----------------------- | ---------------------- | ------------------------------ | --------------- |
| ZSH_DIRJUMP            | string                 | "$HOME/.cache/.zsh_dirjump"    | Path to file to store bookmarked directories. |
 
#### (Optional) Swap Keys 

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

---

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
> New-Item -Path "C:\Program Files\WezTerm\wezterm.lua" -ItemType SymbolicLink -Value "\\wsl.localhost\Ubuntu\home\anthonyhalim\repos\personal\dotfiles\wezterm\wezterm.lua"
> ```

Below is a screenshot of a snippet of the script run:
  
![image](https://github.com/anthony-halim/dotfiles/assets/50617144/2ed8a968-4f67-4555-a6f6-6838503c5229)

---

## 🤔 FAQ

**Q: Why not use third-party keyboard managers?** 

> There are lots of third-party softwares that aid key swapping to an extensive degree of customisation (for example, [Karabiner](https://github.com/pqrs-org/Karabiner-Elements) for MacOS, [xcape](https://github.com/alols/xcape) for Linux). However, you may not want (or be allowed) to install third-party software that customises close to the firmware level. 
>
> Due to this, I opt to use built-in or officially supported by the OS, albeit it supports less extensive customisation.
>
> If you are using third-party software, an idea for customisation is:
> - On `Caps Lock` tap, map it as `Esc`. 
> - On `Caps Lock` hold, map it as `Ctrl`.

