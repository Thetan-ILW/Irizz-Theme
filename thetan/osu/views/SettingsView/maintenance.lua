local GroupContainer = require("thetan.osu.views.SettingsView.GroupContainer")
local Elements = require("thetan.osu.views.SettingsView.Elements")
local Label = require("thetan.osu.ui.Label")
local version = require("version")

---@param assets osu.OsuAssets
---@param view osu.SettingsView
---@return osu.SettingsView.GroupContainer?
return function(assets, view)
	local font = assets.localization.fontGroups.settings

	local settings = view.game.configModel.configs.settings
	local m = settings.miscellaneous

	local c = GroupContainer("MAINTENANCE", font)

	Elements.assets = assets
	Elements.currentContainer = c
	local checkbox = Elements.checkbox

	c:createGroup("version", "VERSION")
	Elements.currentGroup = "version"

	checkbox("Auto update", function()
		return m.autoUpdate
	end, function()
		m.autoUpdate = not m.autoUpdate
	end)

	c:removeEmptyGroups()

	if c.isEmpty then
		return nil
	end

	c:add("version", Label({ text = version.date, font = font.version, width = 438 - 24 - 28 }))

	return c
end
