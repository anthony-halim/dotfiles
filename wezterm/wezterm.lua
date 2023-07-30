-- Pull in the wezterm API
local wezterm = require("wezterm")

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
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.8
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("JetBrains Mono")
config.font_size = 10
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

-- Override keys
config.keys = {
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
	{
		key = "w",
		mods = "CTRL|SHIFT",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
	{
		key = "|",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "_",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
}

-- Finally, return the configuration to wezterm
return config
