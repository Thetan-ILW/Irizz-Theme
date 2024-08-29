local Checkbox = require("thetan.osu.ui.Checkbox")
local Combo = require("thetan.osu.ui.Combo")
local consts = require("thetan.osu.views.SettingsView.Consts")

local Elements = {}

---@type osu.OsuAssets
Elements.assets = nil
---@type osu.SettingsView.GroupContainer
Elements.currentContainer = nil
---@type string
Elements.currentGroup = nil
---@type string
Elements.searchText = ""

local function canAdd(text)
	local search_text = Elements.searchText

	if search_text ~= "" then
		local a = text:lower()
		local b = search_text:lower()
		if not a:find(b) then
			return false
		end
	end

	return true
end

---@param text string
---@param default_value boolean?
---@param tip string?
---@param get_value function
---@param on_change function
function Elements.checkbox(text, default_value, tip, get_value, on_change)
	if not canAdd(text) then
		return
	end

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
			defaultValue = default_value,
		}, get_value, on_change)
	)
end

---@param text string
---@param default_value any?
---@param tip string?
---@param get_value fun(): any, any[]
---@param on_change function
---@param format function?
function Elements.combo(text, default_value, tip, get_value, on_change, format)
	if Elements.searchText ~= "" then
		local _, items = get_value()

		local can_add = false

		for _, v in ipairs(items) do
			can_add = can_add or canAdd(format and format(v) or tostring(v))
		end

		can_add = can_add or canAdd(text)

		if not can_add then
			return
		end
	end

	local assets = Elements.assets
	local font = assets.localization.fontGroups.settings
	local c = Elements.currentContainer
	local current_group = Elements.currentGroup

	c:add(
		current_group,
		Combo(assets, {
			label = text,
			font = font.combos,
			pixelWidth = consts.settingsWidth - consts.tabIndentIndent - consts.tabIndent,
			pixelHeight = consts.comboHeight,
			defaultValue = default_value,
		}, get_value, on_change, format)
	)
end

return Elements
