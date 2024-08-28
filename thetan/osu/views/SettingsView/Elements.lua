local Checkbox = require("thetan.osu.ui.Checkbox")
local consts = require("thetan.osu.views.SettingsView.Consts")

local Elements = {}

---@type osu.OsuAssets
Elements.assets = nil
---@type osu.SettingsView.GroupContainer
Elements.currentContainer = nil
---@type string
Elements.currentGroup = nil

function Elements.checkbox(text, get_value, on_change)
	local assets = Elements.assets
	local font = assets.localization.fontGroups.settings
	local c = Elements.currentContainer
	local current_group = Elements.currentGroup

	c:add(
		current_group,
		Checkbox(assets, {
			text = text,
			font = font.checkboxes,
			pixelWidth = consts.checkboxWidth,
			pixelHeight = consts.checkboxHeight,
		}, get_value, on_change)
	)
end

return Elements
