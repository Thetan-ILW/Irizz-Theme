local GroupContainer = require("thetan.osu.views.SettingsView.GroupContainer")
local Elements = require("thetan.osu.views.SettingsView.Elements")

local vsyncNames = {
	[1] = "enabled",
	[0] = "disabled",
	[-1] = "adaptive",
}

---@param assets osu.OsuAssets
---@param view osu.SettingsView
---@return osu.SettingsView.GroupContainer?
return function(assets, view)
	local text, font = assets.localization:get("settings")
	assert(text and font)

	local settings = view.game.configModel.configs.settings
	local g = settings.graphics
	local gp = settings.gameplay
	local m = settings.miscellaneous
	local flags = g.mode.flags

	local c = GroupContainer(text.graphics, font)

	Elements.assets = assets
	Elements.currentContainer = c
	local checkbox = Elements.checkbox
	local combo = Elements.combo

	--------------- RENDERER ---------------
	c:createGroup("renderer", text.renderer)
	Elements.currentGroup = "renderer"

	combo(text.vsyncType, function()
		return flags.vsync, { 1, 0, -1 }
	end, function(v)
		flags.vsync = v
	end, function(v)
		return text[vsyncNames[v]] or ""
	end)

	checkbox(text.showFPS, function()
		return m.showFPS
	end, function()
		m.showFPS = not m.showFPS
	end)

	checkbox(text.vsyncInSongSelect, function()
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
	c:createGroup("layout", text.layout)
	Elements.currentGroup = "layout"

	combo(text.fullscreenType, function()
		return flags.fullscreentype, { "desktop", "exclusive" }
	end, function(v)
		flags.fullscreentype = v
	end, function(v)
		return text[v]
	end)

	local modes = love.window.getFullscreenModes()
	combo(text.windowResolution, function()
		return g.mode.window, modes
	end, function(v)
		g.mode.window = v
	end, function(mode)
		return mode.width .. "x" .. mode.height
	end)

	checkbox(text.fullscreen, function()
		return flags.fullscreen
	end, function()
		flags.fullscreen = not flags.fullscreen
	end)

	--------------- DETAILS ---------------
	c:createGroup("details", text.details)
	Elements.currentGroup = "details"

	checkbox(text.backgroundVideos, function()
		return gp.bga.video
	end, function()
		gp.bga.video = not gp.bga.video
	end)

	checkbox(text.backgroundImages, function()
		return gp.bga.image
	end, function()
		gp.bga.image = not gp.bga.image
	end)

	c:removeEmptyGroups()

	if c.isEmpty then
		return nil
	end

	return c
end
