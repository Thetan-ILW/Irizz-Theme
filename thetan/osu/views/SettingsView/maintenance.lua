local GroupContainer = require("thetan.osu.views.SettingsView.GroupContainer")
local Elements = require("thetan.osu.views.SettingsView.Elements")
local Label = require("thetan.osu.ui.Label")
local consts = require("thetan.osu.views.SettingsView.Consts")
local version = require("version")

---@param assets osu.OsuAssets
---@param view osu.SettingsView
---@return osu.SettingsView.GroupContainer?
return function(assets, view)
	local text, font = assets.localization:get("settings")
	assert(text and font)

	local settings = view.game.configModel.configs.settings

	local c = GroupContainer(text.maintenance, assets, font, assets.images.maintenanceTab)

	Elements.assets = assets
	Elements.currentContainer = c
	local checkbox = Elements.checkbox

	c:createGroup("maintenance", text.maintenance)
	Elements.currentGroup = "maintenance"

	if Elements.canAdd(version.date) then
		c:add(
			"maintenance",
			Label(
				assets,
				{ text = version.date, font = font.labels, pixelWidth = consts.labelWidth - 24 - 28, pixelHeight = 64 },
				function()
					love.system.openURL("https://github.com/semyon422/soundsphere/commits/master/")
				end
			)
		)
	end

	c:removeEmptyGroups()

	if c.isEmpty then
		return nil
	end

	return c
end
