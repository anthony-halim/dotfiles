-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

local is_macos = string.find(wezterm.target_triple, "darwin")

-- Refactor frequently changed configurations
local windows_window_background_opacity = 0.9
local windows_win32_system_backdrop = "Disable"
local macos_window_background_opacity = 0.6
local macos_window_background_blur = 20
local font_with_fallback = wezterm.font_with_fallback({
  "JetBrains Mono",
  "Symbols Nerd Font Mono",
})
local font_size = 11
local color_scheme_name = "nightfox"
local color_scheme = wezterm.color.get_builtin_schemes()[color_scheme_name]
local use_tab_bar = true

local keymaps = {
  -- Make Ctrl-Left equivalent backward-word
  { key = "LeftArrow",  mods = "CTRL", action = act({ SendString = "\x1bb" }) },
  -- Make Ctrl-Right equivalent forward-word
  { key = "RightArrow", mods = "CTRL", action = act({ SendString = "\x1bf" }) },
  -- Make Alt-Left equivalent to backward-line
  { key = "LeftArrow",  mods = "ALT",  action = act({ SendString = "\x01" }) },
  -- Make Alt-Right equivalent to forward-line
  { key = "RightArrow", mods = "ALT",  action = act({ SendString = "\x05" }) },
  -- Ctrl-C is to copy on text highlight, else do terminate action
  {
    key = "c",
    mods = "CTRL",
    action = wezterm.action_callback(function(window, pane)
      local selection_text = window:get_selection_text_for_pane(pane)
      local is_selection_active = string.len(selection_text) ~= 0
      if is_selection_active then
        window:perform_action(act.CopyTo("Clipboard"), pane)
      else
        window:perform_action(act.SendKey({ key = "c", mods = "CTRL" }), pane)
      end
    end),
  },
  { key = "v",     mods = "CTRL",       action = act({ PasteFrom = "Clipboard" }) },
  { key = "n",     mods = "CTRL",       action = act.SpawnWindow },
  { key = "Enter", mods = "AlT",        action = act.ToggleFullScreen },
  { key = "-",     mods = "CTRL",       action = act.DecreaseFontSize },
  { key = "=",     mods = "CTRL",       action = act.IncreaseFontSize },
  { key = "Tab",   mods = "CTRL|SHIFT", action = act({ ActivateTabRelative = 1 }) },
  { key = "T",     mods = "CTRL|SHIFT", action = act.SpawnCommandInNewTab({ cwd = "~" }) },
  { key = "W",     mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = false }) },
  { key = "r",     mods = "CTRL",       action = act.ReloadConfiguration },
  { key = "L",     mods = "CTRL|SHIFT", action = act.ShowDebugOverlay },
  { key = "P",     mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
  { key = "f",     mods = "CTRL",       action = act.Search({ CaseSensitiveString = "" }) },
  { key = "F",     mods = "CTRL|SHIFT", action = act.Search({ CaseInSensitiveString = "" }) },
}

-- This table will hold the configuration
local config = {}

-- In newer version of wezterm, use the config_builder which will
-- help provide clearer error message
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Start in Ubuntu for WSL
local wsl_domains = wezterm.default_wsl_domains()
if #wsl_domains > 0 then
  local _, wsl_domain = next(wsl_domains)
  config.default_domain = wsl_domain.name
end

-- Exit behaviour
config.exit_behavior = "Close"
config.window_close_confirmation = "NeverPrompt"

-- Editor
config.font = font_with_fallback
config.font_size = font_size

-- Colors
config.color_scheme = color_scheme_name

-- Tab
config.enable_tab_bar = use_tab_bar
if use_tab_bar then
  config.hide_tab_bar_if_only_one_tab = true
  config.use_fancy_tab_bar = true
  config.colors = {
    tab_bar = color_scheme.tab_bar,
  }
end

-- Window
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

-- Override keys
config.disable_default_key_bindings = true
config.keys = keymaps

-- Warnings
config.warn_about_missing_glyphs = false

-- OS specific settings
if is_macos then
  config.window_background_opacity = macos_window_background_opacity
  config.macos_window_background_blur = macos_window_background_blur
else
  config.window_background_opacity = windows_window_background_opacity
  config.win32_system_backdrop = windows_win32_system_backdrop
end

-- Finally, return the configuration to wezterm
return config
