-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

local is_macos = string.find(wezterm.target_triple, "darwin")

-- Refactor frequently changed configurations
local windows_window_background_opacity = 0.8
local windows_win32_system_backdrop = "Disable"
local macos_window_background_opacity = 0.6
local macos_window_background_blur = 20
local font_with_fallback = wezterm.font_with_fallback({
	"JetBrains Mono",
	"Symbols Nerd Font Mono",
})
local font_size = 10
local color_scheme_name = "nightfox"
local color_scheme = wezterm.color.get_builtin_schemes()[color_scheme_name]

-- Key bindings
local macos_keybindings = {
	-- Make Opt-Left equivalent to backward-word
	{ key = "LeftArrow", mods = "OPT", action = act({ SendString = "\x1bb" }) },
	-- Make Opt-Right equivalent to forward-word
	{ key = "RightArrow", mods = "OPT", action = act({ SendString = "\x1bf" }) },
	-- Make Cmd-Left equivalent to backward-line
	{ key = "LeftArrow", mods = "SUPER", action = act({ SendString = "\x01" }) },
	-- Make Cmd-Right equivalent to forward-line
	{ key = "RightArrow", mods = "SUPER", action = act({ SendString = "\x05" }) },
	{ key = "c", mods = "SUPER", action = act({ CopyTo = "Clipboard" }) },
	{ key = "v", mods = "SUPER", action = act({ PasteFrom = "Clipboard" }) },
	{ key = "n", mods = "SUPER", action = act.SpawnWindow },
	{ key = "Enter", mods = "OPT", action = act.ToggleFullScreen },
	{ key = "-", mods = "SUPER", action = act.DecreaseFontSize },
	{ key = "=", mods = "SUPER", action = act.IncreaseFontSize },
	{ key = "t", mods = "SUPER", action = act.SpawnCommandInNewTab({ cwd = "~" }) },
	{ key = "w", mods = "SUPER", action = act.CloseCurrentPane({ confirm = false }) },
	{ key = "W", mods = "SUPER|SHIFT", action = act.CloseCurrentTab({ confirm = false }) },
	{ key = "1", mods = "SUPER", action = act({ ActivateTab = 0 }) },
	{ key = "2", mods = "SUPER", action = act({ ActivateTab = 1 }) },
	{ key = "3", mods = "SUPER", action = act({ ActivateTab = 2 }) },
	{ key = "4", mods = "SUPER", action = act({ ActivateTab = 3 }) },
	{ key = "5", mods = "SUPER", action = act({ ActivateTab = 4 }) },
	{ key = "6", mods = "SUPER", action = act({ ActivateTab = 5 }) },
	{ key = "7", mods = "SUPER", action = act({ ActivateTab = 6 }) },
	{ key = "8", mods = "SUPER", action = act({ ActivateTab = 7 }) },
	{ key = "9", mods = "SUPER", action = act({ ActivateTab = -1 }) },
	{ key = "Tab", mods = "SUPER", action = act({ ActivateTabRelative = 1 }) },
	{ key = "Tab", mods = "SUPER|SHIFT", action = act({ ActivateTabRelative = -1 }) },
	{ key = "r", mods = "SUPER", action = act.ReloadConfiguration },
	{ key = "L", mods = "SUPER|SHIFT", action = act.ShowDebugOverlay },
	{ key = "P", mods = "SUPER|SHIFT", action = act.ActivateCommandPalette },
	{ key = "f", mods = "SUPER", action = act.Search({ CaseSensitiveString = "" }) },
	{ key = "F", mods = "SUPER|SHIFT", action = act.Search({ CaseInSensitiveString = "" }) },
	{ key = "|", mods = "SUPER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "_", mods = "SUPER|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "H", mods = "SUPER|SHIFT|OPT", action = act.AdjustPaneSize({ "Left", 1 }) },
	{ key = "J", mods = "SUPER|SHIFT|OPT", action = act.AdjustPaneSize({ "Down", 1 }) },
	{ key = "K", mods = "SUPER|SHIFT|OPT", action = act.AdjustPaneSize({ "Up", 1 }) },
	{ key = "L", mods = "SUPER|SHIFT|OPT", action = act.AdjustPaneSize({ "Right", 1 }) },
	{ key = "H", mods = "SUPER|SHIFT", action = act({ ActivatePaneDirection = "Left" }) },
	{ key = "J", mods = "SUPER|SHIFT", action = act({ ActivatePaneDirection = "Down" }) },
	{ key = "K", mods = "SUPER|SHIFT", action = act({ ActivatePaneDirection = "Up" }) },
	{ key = "L", mods = "SUPER|SHIFT", action = act({ ActivatePaneDirection = "Right" }) },
	{ key = "Z", mods = "SUPER|SHIFT", action = act.TogglePaneZoomState },
	{
		key = ">",
		mods = "SUPER|SHIFT",
		action = act.SplitPane({
			direction = "Down",
			size = { Percent = 20 },
			command = { domain = "CurrentPaneDomain" },
		}),
	},
	-- Some options are doubled from windows
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
	{ key = "v", mods = "CTRL", action = act({ PasteFrom = "Clipboard" }) },
	{ key = "H", mods = "CTRL|SHIFT", action = act({ ActivatePaneDirection = "Left" }) },
	{ key = "J", mods = "CTRL|SHIFT", action = act({ ActivatePaneDirection = "Down" }) },
	{ key = "K", mods = "CTRL|SHIFT", action = act({ ActivatePaneDirection = "Up" }) },
	{ key = "L", mods = "CTRL|SHIFT", action = act({ ActivatePaneDirection = "Right" }) },
}

local windows_keybindings = {
	-- Make Ctrl-Left equivalent backward-word
	{ key = "LeftArrow", mods = "CTRL", action = act({ SendString = "\x1bb" }) },
	-- Make Ctrl-Right equivalent forward-word
	{ key = "RightArrow", mods = "CTRL", action = act({ SendString = "\x1bf" }) },
	-- Make Alt-Left equivalent to backward-line
	{ key = "LeftArrow", mods = "ALT", action = act({ SendString = "\x01" }) },
	-- Make Alt-Right equivalent to forward-line
	{ key = "RightArrow", mods = "ALT", action = act({ SendString = "\x05" }) },
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
	{ key = "v", mods = "CTRL", action = act({ PasteFrom = "Clipboard" }) },
	{ key = "n", mods = "CTRL", action = act.SpawnWindow },
	{ key = "Enter", mods = "ALT", action = act.ToggleFullScreen },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "=", mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "t", mods = "CTRL", action = act.SpawnCommandInNewTab({ cwd = "~" }) },
	{ key = "w", mods = "CTRL", action = act.CloseCurrentPane({ confirm = false }) },
	{ key = "W", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = false }) },
	{ key = "1", mods = "CTRL", action = act({ ActivateTab = 0 }) },
	{ key = "2", mods = "CTRL", action = act({ ActivateTab = 1 }) },
	{ key = "3", mods = "CTRL", action = act({ ActivateTab = 2 }) },
	{ key = "4", mods = "CTRL", action = act({ ActivateTab = 3 }) },
	{ key = "5", mods = "CTRL", action = act({ ActivateTab = 4 }) },
	{ key = "6", mods = "CTRL", action = act({ ActivateTab = 5 }) },
	{ key = "7", mods = "CTRL", action = act({ ActivateTab = 6 }) },
	{ key = "8", mods = "CTRL", action = act({ ActivateTab = 7 }) },
	{ key = "9", mods = "CTRL", action = act({ ActivateTab = -1 }) },
	{ key = "Tab", mods = "CTRL", action = act({ ActivateTabRelative = 1 }) },
	{ key = "Tab", mods = "CTRL|SHIFT", action = act({ ActivateTabRelative = -1 }) },
	{ key = "r", mods = "CTRL", action = act.ReloadConfiguration },
	{ key = "L", mods = "CTRL|SHIFT", action = act.ShowDebugOverlay },
	{ key = "P", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
	{ key = "f", mods = "CTRL", action = act.Search({ CaseSensitiveString = "" }) },
	{ key = "F", mods = "CTRL|SHIFT", action = act.Search({ CaseInSensitiveString = "" }) },
	{ key = "|", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "_", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "H", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Left", 1 }) },
	{ key = "J", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Down", 1 }) },
	{ key = "K", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Up", 1 }) },
	{ key = "L", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Right", 1 }) },
	{ key = "H", mods = "CTRL|SHIFT", action = act({ ActivatePaneDirection = "Left" }) },
	{ key = "J", mods = "CTRL|SHIFT", action = act({ ActivatePaneDirection = "Down" }) },
	{ key = "K", mods = "CTRL|SHIFT", action = act({ ActivatePaneDirection = "Up" }) },
	{ key = "L", mods = "CTRL|SHIFT", action = act({ ActivatePaneDirection = "Right" }) },
	{ key = "Z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },
	{
		key = ">",
		mods = "CTRL|SHIFT",
		action = act.SplitPane({
			direction = "Down",
			size = { Percent = 20 },
			command = { domain = "CurrentPaneDomain" },
		}),
	},
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

-- Override keys
config.disable_default_key_bindings = true

-- OS specific settings
if is_macos then
	config.keys = macos_keybindings
	config.window_background_opacity = macos_window_background_opacity
	config.macos_window_background_blur = macos_window_background_blur
else
	config.keys = windows_keybindings
	config.window_background_opacity = windows_window_background_opacity
	config.win32_system_backdrop = windows_win32_system_backdrop
end

-- Finally, return the configuration to wezterm
return config
