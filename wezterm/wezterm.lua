-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

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
config.disable_default_key_bindings = true
config.keys = {
	-- MacOS binding
	-- Make Option-Left equivalent to Alt-b; backward-word
	{
		key = "LeftArrow",
		mods = "OPT",
		action = act({ SendString = "\x1bb" }),
	},
	-- Make Option-Right equivalent to Alt-f; forward-word
	{
		key = "RightArrow",
		mods = "OPT",
		action = act({ SendString = "\x1bf" }),
	},
	{
		key = "c",
		mods = "SUPER",
		action = act({ CopyTo = "Clipboard" }),
	},
	{
		key = "v",
		mods = "SUPER",
		action = act({ PasteFrom = "Clipboard" }),
	},
	{ key = "n", mods = "SUPER", action = act.SpawnWindow },
	{ key = "Enter", mods = "OPT", action = act.ToggleFullScreen },
	{ key = "-", mods = "SUPER", action = act.DecreaseFontSize },
	{ key = "=", mods = "SUPER", action = act.IncreaseFontSize },
	{
		key = "t",
		mods = "SUPER",
		action = act({ SpawnTab = "CurrentPaneDomain" }),
	},
	{
		key = "w",
		mods = "SUPER",
		action = act.CloseCurrentTab({ confirm = false }),
	},
	{ key = "1", mods = "SUPER", action = act({ ActivateTab = 0 }) },
	{ key = "2", mods = "SUPER", action = act({ ActivateTab = 1 }) },
	{ key = "3", mods = "SUPER", action = act({ ActivateTab = 2 }) },
	{ key = "4", mods = "SUPER", action = act({ ActivateTab = 3 }) },
	{ key = "5", mods = "SUPER", action = act({ ActivateTab = 4 }) },
	{ key = "6", mods = "SUPER", action = act({ ActivateTab = 5 }) },
	{ key = "7", mods = "SUPER", action = act({ ActivateTab = 6 }) },
	{ key = "8", mods = "SUPER", action = act({ ActivateTab = 7 }) },
	{ key = "9", mods = "SUPER", action = act({ ActivateTab = -1 }) },
	{
		key = "Tab",
		mods = "SUPER",
		action = act({ ActivateTabRelative = 1 }),
	},
	{
		key = "Tab",
		mods = "SUPER|SHIFT",
		action = act({ ActivateTabRelative = -1 }),
	},
	{ key = "r", mods = "SUPER", action = act.ReloadConfiguration },
	{ key = "L", mods = "SUPER|SHIFT", action = act.ShowDebugOverlay },
	{ key = "P", mods = "SUPER|SHIFT", action = act.ActivateCommandPalette },
	{
		key = "f",
		mods = "SUPER",
		action = act.Search({ CaseInSensitiveString = "" }),
	},
	{
		key = "|",
		mods = "SUPER|SHIFT",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "_",
		mods = "SUPER|SHIFT",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "LeftArrow",
		mods = "SUPER|SHIFT|OPT",
		action = act.AdjustPaneSize({ "Left", 1 }),
	},
	{
		key = "RightArrow",
		mods = "SUPER|SHIFT|OPT",
		action = act.AdjustPaneSize({ "Right", 1 }),
	},
	{
		key = "UpArrow",
		mods = "SUPER|SHIFT|OPT",
		action = act.AdjustPaneSize({ "Up", 1 }),
	},
	{
		key = "DownArrow",
		mods = "SUPER|SHIFT|OPT",
		action = act.AdjustPaneSize({ "Down", 1 }),
	},
	{
		key = "LeftArrow",
		mods = "SUPER|SHIFT",
		action = act({ ActivatePaneDirection = "Left" }),
	},
	{
		key = "RightArrow",
		mods = "SUPER|SHIFT",
		action = act({ ActivatePaneDirection = "Right" }),
	},
	{
		key = "UpArrow",
		mods = "SUPER|SHIFT",
		action = act({ ActivatePaneDirection = "Up" }),
	},
	{
		key = "DownArrow",
		mods = "SUPER|SHIFT",
		action = act({ ActivatePaneDirection = "Down" }),
	},
	{ key = "Z", mods = "SUPER|SHIFT", action = act.TogglePaneZoomState },
	{
		key = ">",
		mods = "SUPER|SHIFT",
		action = act.SplitPane({ direction = "Down", size = { Percent = 20 } }),
	},
	-- Windows binding
	{
		key = "c",
		mods = "CTRL",
		action = act({ CopyTo = "Clipboard" }),
	},
	{
		key = "v",
		mods = "CTRL",
		action = act({ PasteFrom = "Clipboard" }),
	},
	{ key = "n", mods = "CTRL", action = act.SpawnWindow },
	{ key = "Enter", mods = "ALT", action = act.ToggleFullScreen },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "=", mods = "CTRL", action = act.IncreaseFontSize },
	{
		key = "t",
		mods = "CTRL",
		action = act({ SpawnTab = "CurrentPaneDomain" }),
	},
	{
		key = "w",
		mods = "CTRL",
		action = act.CloseCurrentTab({ confirm = false }),
	},
	{ key = "1", mods = "CTRL", action = act({ ActivateTab = 0 }) },
	{ key = "2", mods = "CTRL", action = act({ ActivateTab = 1 }) },
	{ key = "3", mods = "CTRL", action = act({ ActivateTab = 2 }) },
	{ key = "4", mods = "CTRL", action = act({ ActivateTab = 3 }) },
	{ key = "5", mods = "CTRL", action = act({ ActivateTab = 4 }) },
	{ key = "6", mods = "CTRL", action = act({ ActivateTab = 5 }) },
	{ key = "7", mods = "CTRL", action = act({ ActivateTab = 6 }) },
	{ key = "8", mods = "CTRL", action = act({ ActivateTab = 7 }) },
	{ key = "9", mods = "CTRL", action = act({ ActivateTab = -1 }) },
	{
		key = "Tab",
		mods = "CTRL",
		action = act({ ActivateTabRelative = 1 }),
	},
	{
		key = "Tab",
		mods = "CTRL|SHIFT",
		action = act({ ActivateTabRelative = -1 }),
	},
	{ key = "r", mods = "CTRL", action = act.ReloadConfiguration },
	{ key = "L", mods = "CTRL|SHIFT", action = act.ShowDebugOverlay },
	{ key = "P", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
	{
		key = "f",
		mods = "CTRL",
		action = act.Search({ CaseInSensitiveString = "" }),
	},
	{
		key = "|",
		mods = "CTRL|SHIFT",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "_",
		mods = "CTRL|SHIFT",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "LeftArrow",
		mods = "CTRL|SHIFT|ALT",
		action = act.AdjustPaneSize({ "Left", 1 }),
	},
	{
		key = "RightArrow",
		mods = "CTRL|SHIFT|ALT",
		action = act.AdjustPaneSize({ "Right", 1 }),
	},
	{
		key = "UpArrow",
		mods = "CTRL|SHIFT|ALT",
		action = act.AdjustPaneSize({ "Up", 1 }),
	},
	{
		key = "DownArrow",
		mods = "CTRL|SHIFT|ALT",
		action = act.AdjustPaneSize({ "Down", 1 }),
	},
	{
		key = "LeftArrow",
		mods = "CTRL|SHIFT",
		action = act({ ActivatePaneDirection = "Left" }),
	},
	{
		key = "RightArrow",
		mods = "CTRL|SHIFT",
		action = act({ ActivatePaneDirection = "Right" }),
	},
	{
		key = "UpArrow",
		mods = "CTRL|SHIFT",
		action = act({ ActivatePaneDirection = "Up" }),
	},
	{
		key = "DownArrow",
		mods = "CTRL|SHIFT",
		action = act({ ActivatePaneDirection = "Down" }),
	},
	{ key = "Z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },
	{
		key = ">",
		mods = "CTRL|SHIFT",
		action = act.SplitPane({ direction = "Down", size = { Percent = 20 } }),
	},
}

-- Finally, return the configuration to wezterm
return config
