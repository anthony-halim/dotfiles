# Neovim Configuration

A minimal Neovim configuration that prefers native APIs and built-in workflows over third-party abstractions where possible. It leverages standard runtimepath directory structures for native loading alongside Neovim 0.12+'s built-in package manager (`vim.pack`).

## Directory Structure

```
nvim/
├── init.lua                 # Core editor engine: options, keymaps, LSP, Treesitter, conform
├── nvim-pack-lock.json      # Lockfile pinned by Neovim's native package manager (vim.pack)
├── stylua.toml              # Lua formatting rules for stylua
├── plugin/                  # Standalone plugin configurations (auto-loaded by Neovim)
├── ftplugin/                # Buffer-specific settings (auto-loaded per filetype)
├── lua/
│   ├── config.lua           # Shared static settings (diagnostic/git icons, constants)
│   └── utils.lua            # Floating terminal, git helpers, LSP progress
└── after/                   # (Git-ignored) Machine-specific overrides for work/home
```

## The Boot Lifecycle

The loading sequence is as follows:

1. `init.lua`
   - Core configuration and options
   - Keymaps and autocmds
   - LSP server installation and setup
   - Formatters and Treesitter parsers

2. `plugin/*.lua` (loaded automatically in alphabetical order)
   - Each file calls `vim.pack.add(...)` for its plugin
   - Runs `require("...").setup(...)`
   - Binds plugin-specific keymaps (e.g., `<leader>ff`)

3. `ftplugin/<filetype>.lua` (loaded when opening a buffer matching the filetype)
   - Buffer-local options
   - Language-specific buffer overrides

4. `after/*.lua` (machine-local overrides, not tracked in Git)

## How-Tos

**Where to Add or Change Keymaps**

- _General / Editor Keymaps (e.g., windows, splits, jumps, buffers)_: In `init.lua` under the `-- Keymaps` block.
- _LSP Keymaps_: In `init.lua` inside the `LspAttach` autocommand callback.
- _Plugin-Specific Keymaps_: Directly inside the corresponding `plugin/<plugin_name>.lua` file.
- _Keymap Prefix Descriptions_: In `plugin/which_key.lua`.

**How to Add or Configure a Language / LSP Server**

1. In `init.lua`, locate the `lsp_confs` table under the `LSP installation` section. Add your server (Mason will auto-install it via `ensure_installed`).
2. If the language needs code formatting, add it to `formatters_by_ft` under the `conform.nvim` section in `init.lua`.

**Custom Commands**

- `:PackUpdate`: Inspect pending updates and commit changelogs in a diff buffer (`:w` to apply, `:q` to cancel).
- `:PackUpdate!`: Force-update all packages immediately without confirmation.
- `:PackClean`: Prune inactive/removed plugins from disk and `nvim-pack-lock.json`.
- `:AutoFormatToggle`: Toggle automatic format-on-save on or off globally.

## Pending Items

- [ ] Language settings are split between `lsp_confs` and `conform.nvim`'s `formatters_by_ft`. Consolidate into a unified mapping: `Language <-> FileType <-> LSP Server <-> Formatter`.
- [ ] (Blocked until upgrade to 0.13) Remove `checktime` autocmd in `init.lua` (`autoread` uses native OS filesystem watchers).
- [ ] (Blocked until upgrade to 0.13) Remove `vim.keymap.set("n", "Q", "<nop>")` in `init.lua` to enable native multi-cursor support.
- [ ] (Blocked until upgrade to 0.13) Explore replacing browser-based `markdown-preview.nvim` with native terminal image preview (`vim.ui.img`).
