-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

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
  if wsl_domain then
    config.default_domain = wsl_domain.name
  end
end

-- Editor
config.font = wezterm.font_with_fallback({
  "JetBrainsMonoNL Nerd Font Propo",
  "Symbols Nerd Font Mono",
})
config.font_dirs = { "fonts" } -- directory is relative to the wezterm.lua
config.font_size = 10
config.warn_about_missing_glyphs = false
config.hide_tab_bar_if_only_one_tab = true
config.color_scheme = "catppuccin-mocha"
config.exit_behavior = "Close"

-- Window
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
config.window_background_opacity = 1.0
config.window_close_confirmation = "NeverPrompt"

-- Window OS specific settings
config.macos_window_background_blur = 20
config.win32_system_backdrop = "Disable"

-- Keys
config.disable_default_key_bindings = true
config.keys = {
  { key = "v",     mods = "CTRL",       action = act({ PasteFrom = "Clipboard" }) },
  { key = "-",     mods = "CTRL",       action = act.DecreaseFontSize },
  { key = "=",     mods = "CTRL",       action = act.IncreaseFontSize },
  { key = "~",     mods = "CTRL|SHIFT", action = act.ShowDebugOverlay },
  { key = "Enter", mods = "CTRL|SHIFT", action = act.ToggleFullScreen },
  { key = "R",     mods = "CTRL|SHIFT", action = act.ReloadConfiguration },
  { key = "Q",     mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = false }) },
}

-- Finally, return the configuration to wezterm
return config
