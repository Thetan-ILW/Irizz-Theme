local GroupContainer = require("thetan.osu.views.SettingsView.GroupContainer")
local Elements = require("thetan.osu.views.SettingsView.Elements")

local vsyncNames = {
	[1] = "Enabled",
	[0] = "Disabled",
	[-1] = "Adaptive",
}

---@param assets osu.OsuAssets
---@param view osu.SettingsView
---@return osu.SettingsView.GroupContainer?
return function(assets, view)
	local font = assets.localization.fontGroups.settings

	local settings = view.game.configModel.configs.settings
	local g = settings.graphics
	local m = settings.miscellaneous
	local flags = g.mode.flags

	local c = GroupContainer("GRAPHICS", font)

	Elements.assets = assets
	Elements.currentContainer = c
	local checkbox = Elements.checkbox
	local combo = Elements.combo

	--------------- RENDERER ---------------
	c:createGroup("renderer", "RENDERER")
	Elements.currentGroup = "renderer"

	combo("Vsync type:", function()
		return flags.vsync, { 1, 0, -1 }
	end, function(v)
		flags.vsync = v
	end, function(v)
		return vsyncNames[v] or ""
	end)

	checkbox("Show FPS counter", function()
		return m.showFPS
	end, function()
		m.showFPS = not m.showFPS
	end)

	checkbox("Vsync in song select", function()
		return g.vsyncOnSelect
	end, function()
		g.vsyncOnSelect = not g.vsyncOnSelect
	end)

	checkbox("DWM flush", function()
		return g.dwmflush
	end, function()
		g.dwmflush = not g.dwmflush
	end)

	--------------- LAYOUT ---------------
	c:createGroup("layout", "LAYOUT")
	Elements.currentGroup = "layout"

	checkbox("Fullscreen mode", function()
		return flags.fullscreen
	end, function()
		flags.fullscreen = not flags.fullscreen
	end)

	c:removeEmptyGroups()

	if c.isEmpty then
		return nil
	end

	return c
end
