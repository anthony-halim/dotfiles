-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration
local config = {}
local color_scheme_name = "nightfox"
local color_scheme = wezterm.color.get_builtin_schemes()[color_scheme_name]

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
config.font = wezterm.font("JetBrains Mono")
config.font_size = 10

-- Colors
config.color_scheme = color_scheme_name

-- Tab
config.use_fancy_tab_bar = true
config.colors = {
	tab_bar = color_scheme.tab_bar,
}

-- Window
config.window_padding = {
	left = 0,
	right = 0,
	top = "0.3cell",
	bottom = 0,
}
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.integrated_title_button_alignment = "Right"
config.window_background_opacity = 0.8
config.macos_window_background_blur = 20

-- Override keys
config.keys = {
	{
		key = "W",
		mods = "SUPER|SHIFT",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
	{
		key = "W",
		mods = "CTRL|SHIFT",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
	{
		key = "|",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "|",
		mods = "SUPER|SHIFT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "_",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "_",
		mods = "SUPER|SHIFT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = ">",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitPane({
			direction = "Down",
			size = { Percent = 20 },
		}),
	},
	{
		key = ">",
		mods = "SUPER|SHIFT",
		action = wezterm.action.SplitPane({
			direction = "Down",
			size = { Percent = 20 },
		}),
	},
}

-- Finally, return the configuration to wezterm
return config
