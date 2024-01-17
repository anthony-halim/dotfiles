# 🦔 Dotfiles

![GitHub repo size](https://img.shields.io/github/repo-size/anthony-halim/dotfiles)
![GitHub commit month activity](https://img.shields.io/github/commit-activity/m/anthony-halim/dotfiles)
![image](https://github.com/anthony-halim/dotfiles/assets/50617144/ec9016d6-9c54-4f8b-af49-8d1b0f74e727)

This repository holds my local configurations. Feel free to take ideas from it to improve your own dotfiles.

> ❗If you want to use this repository, I recommend forking this repository before usage.
> I do **unannounced breaking changes** regularly.

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

See adding [custom local configs](#optional-add-custom-local-configurations).

#### Budget version of [z](https://github.com/rupa/z) for directory traverse: `bm` and `goto`

For those have not checked out [z](https://github.com/rupa/z), I recommend trying it out for fast travels between directories. This repository provides a *budget version* of `z`, powered by [fzf](https://github.com/junegunn/fzf): `bm (bookmark)` and `goto`.

- `bm` bookmarks the current directory.
- `goto` fast travels to the directory e.g. `goto foo`, where `foo` is a fuzzy match to the full path.
- On name conflict, `fzf` window will be spawned.

#### Notes Taking

This repository provides shortcuts to enable [Zettlekasten](https://zettelkasten.de/posts/overview/) style of note taking. It depends on [Neovim](neovim.io) and [telekasten.nvim](https://github.com/renerocksai/telekasten.nvim) plugin.

- Notes are markdown file based. This avoids additional GUI or application to view the notes.
- The followings shortcuts are provided to increase ease of use:

  <details>
    <summary>Shortcuts</summary>
    <br/>

    - `nfind` find notes by title
    - `ngrep` find notes by content grep
    - `ntags` find notes by tags
    - `nnew` create new notes
    - `ntmplnew` create new templated note
    - `npush` commits and push note repository to upstream branch
    - `npull` pull latest changes of note repository from upstream branch
  </details>

  For more information and usage, see [notes.zsh](zsh/config/functions/notes.zsh).

---

## 🧱 Components

#### Terminal: [Wezterm](https://wezfurlong.org/wezterm/index.html) (Terminal emulator), [Zellij](https://github.com/zellij-org/zellij) (Session manager), [ZSH](https://en.wikipedia.org/wiki/Z_shell) (Shell), [Zap](https://www.zapzsh.org/) (ZSH plugin manager), [Starship](https://starship.rs/) (prompt)

<details>
  <br/>

  - Due to heavy TUI usage, terminal performance becomes one of the priority. Wezterm is a cross-platform, performant terminal emulator that is able to satisfy the performance requirements and be configured easily.
  - Zellij is used to provide terminal session management and multiplexer.
  - ZSH is battle tested shell that is easily configurable and is widely supported. [Zap](https://www.zapzsh.org/) as plugin manager.
  - Starship as customisable shell prompt.
</details>

<details>
  <summary>Showcase</summary>
  <br/>

  ![image](https://github.com/anthony-halim/dotfiles/assets/50617144/ec9016d6-9c54-4f8b-af49-8d1b0f74e727)
</details>

#### Shell highlighter and utilities: [eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat), [lazygit](https://github.com/jesseduffield/lazygit), [delta](https://github.com/dandavison/delta), [fzf](https://github.com/junegunn/fzf), [fd](https://github.com/sharkdp/fd), [ripgrep](https://github.com/BurntSushi/ripgrep), [tldr](https://tldr.sh/)

<details>
  <br/>

  - `eza` as better `ls`. Aliased to `ls`.
  - `bat` as better `cat`. Aliased to `cat`.
  - `lazygit` as simple Git terminal UI.
  - `delta` as syntax highlighter for Git.
  - `fzf`, `fd`, `ripgrep` as search utilities.
  - `tldr` as simplified `man` pages.
</details>

<details>
  <summary>Showcase</summary>
  <br/>

  *eza*

  ![credit to source repository](https://github.com/eza-community/eza/blob/main/docs/images/screenshots.png)

  *bat*

  ![credit to source repository](https://camo.githubusercontent.com/7b7c397acc5b91b4c4cf7756015185fe3c5f700f70d256a212de51294a0cf673/68747470733a2f2f696d6775722e636f6d2f724773646e44652e706e67)

  *lazygit*

  ![credit to source repository](https://github.com/jesseduffield/lazygit/blob/assets/demo/commit_and_push-compressed.gif)

  *delta*

  ![credit to source repository](https://user-images.githubusercontent.com/50617144/266825290-21025bbd-89c4-4ff7-ba81-81a273604632.png)

  *tldr*
  ![credit to source repository](https://tldr.sh/assets/img/screenshot.png)
</details>

#### Editor: [Neovim](neovim.io) (Text editor)

<details>
  <br/>

  - Neovim is able to be extensively configured to become a `Personal Development Environment (PDE)`, and having to not use multiple IDE for individual languages is much welcomed.
  - The Neovim has been configured to include LSP, auto-completion, UI and quality of life plugins that I use often.
  - Note taking with [Telekasten.nvim](https://github.com/renerocksai/telekasten.nvim)
</details>

<details>
  <summary>Showcase</summary>
  <br/>

  ![image](https://github.com/anthony-halim/dotfiles/assets/50617144/a56fb5c1-da8a-4b36-bde0-53dddc2d0540)
</details>

#### Programming languages and utilities: Golang, Python, Rust

<details>
  <br/>

  - Programming languages and their utility tools that I often use e.g. [Golang](https://go.dev/), [Rust](https://www.rust-lang.org/), [pyenv](https://github.com/pyenv/pyenv) are installed by default.
</details>

---

## 🌱  Usage

#### Git clone this repository

Git clone to the machine.

```sh
git clone --depth=1 https://github.com/anthony-halim/dotfiles.git
```

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

#### (Optional) Add custom local configurations

The followings **will not** be committed to the repository and are suitable to add a local/machine specific configuration.

##### `zsh/local_config/exports.zsh`

This file is to load local environment variables.
Environment variables must be loaded before the rest of shell configuration is done as it dictates the behaviour.

The following environment variables are supported.

<details>
  <summary>Notes</summary>


  | Name                       | Type                   | Defaults                 | Description     |
  |--------------------------- | ---------------------- | ------------------------ | --------------- |
  | NOTES_DEFAULT_VAULT        | "personal"\|"work"     | "personal"               | Default vault (notes directory) to be used on load. |
  | NOTES_WORK_VAULT           | string                 | "$HOME/notes/work"       | Path to work notes vault (notes directory).         |
  | NOTES_PERSONAL_VAULT       | string                 | "$HOME/notes/personal"   | Path to personal notes vault (notes directory)      |
  | NOTES_DEFAULT_GIT_UPSTREAM | string                 | "origin"                 | Default git upstream to commit notes to.            |
  | NOTES_DEFAULT_GIT_BRANCH   | string                 | "main"                   | Default git branch to commit notes to.              |
</details>

<details>
  <summary>ZSH</summary>


  | Name                   | Type                   | Defaults                       | Description     |
  |----------------------- | ---------------------- | ------------------------------ | --------------- |
  | ZSH_DIRJUMP            | string                 | "$HOME/.cache/.dirjump"        | Path to file to store bookmarked directories. |
</details>

<details>
  <summary>Zellij</summary>


  | Name                   | Type                   | Defaults                       | Description     |
  |----------------------- | ---------------------- | ------------------------------ | --------------- |
  | ZELLIJ_AUTO_START      | bool                   | false                          | Automatically start zellij on shell start.    |
  | ZELLIJ_AUTO_ATTACH     | bool                   | false                          | Automatically attach to zellij session if any.|
</details>

<details>
  <summary>Neovim</summary>

  | Name                       | Type                   | Defaults                 | Description                             |
  |--------------------------- | ---------------------- | ------------------------ | --------------------------------------- |
  | NVIM_EXTRA_NOTES           | boolean                | true                     | Enable notes related plugins in Neovim. |
  | NVIM_EXTRA_BIBLE           | boolean                | false                    | Enable Bible related plugins in Neovim. |
</details>

##### `zsh/local_config/*.zsh`

Any `*.zsh` file in this directory will be automatically loaded during ZSH initialisation. You can use this to add additional aliases or functions.

##### `nvim/lua/local_config/(options|keymaps|autocmds).lua`

***options.lua***

Load local Neovim options.

***keymaps.lua***

Load local Neovim keymaps.

***autocmds.lua***

Load local Neovim autocmds.



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
                     [--golang_tag golang_semver]
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

![image](https://github.com/anthony-halim/dotfiles/assets/50617144/80ae74d0-fc35-4ae2-96ba-e394df959f93)

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


**Q: The Diatheke module is not installed correctly.**
> Try to completely uninstall module `installmgr -u <module_name>` and rerun `./setup.sh` again.


**Q: The [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) Neovim plugin is not installed correctly.**
> Try to upgrade `Node` and `npm` to the latest version and restart Neovim.
