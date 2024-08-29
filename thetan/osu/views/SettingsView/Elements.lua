local Checkbox = require("thetan.osu.ui.Checkbox")
local Combo = require("thetan.osu.ui.Combo")
local Slider = require("thetan.osu.ui.Slider")
local Button = require("thetan.osu.ui.Button")
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

---@param label string
---@param default_value boolean?
---@param tip string?
---@param get_value function
---@param on_change function
function Elements.checkbox(label, default_value, tip, get_value, on_change)
	if not canAdd(label) then
		return
	end

	local assets = Elements.assets
	local font = assets.localization.fontGroups.settings
	local c = Elements.currentContainer
	local current_group = Elements.currentGroup

	c:add(
		current_group,
		Checkbox(assets, {
			text = label,
			font = font.checkboxes,
			pixelWidth = consts.checkboxWidth,
			pixelHeight = consts.checkboxHeight,
			defaultValue = default_value,
		}, get_value, on_change)
	)
end

---@param label string
---@param default_value any?
---@param tip string?
---@param get_value fun(): any, any[]
---@param on_change function
---@param format function?
function Elements.combo(label, default_value, tip, get_value, on_change, format)
	if Elements.searchText ~= "" then
		local _, items = get_value()

		local can_add = false

		for _, v in ipairs(items) do
			can_add = can_add or canAdd(format and format(v) or tostring(v))
		end

		can_add = can_add or canAdd(label)

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
			label = label,
			font = font.combos,
			pixelWidth = consts.settingsWidth - consts.tabIndentIndent - consts.tabIndent,
			pixelHeight = consts.comboHeight,
			defaultValue = default_value,
		}, get_value, on_change, format)
	)
end

---@type number?
Elements.sliderPixelWidth = nil

---@param label string
---@param default_value any?
---@param tip string?
---@param get_value fun(): any, any[]
---@param on_change function
---@param format function?
function Elements.slider(label, default_value, tip, get_value, on_change, format)
	if not canAdd(label) then
		return
	end

	local assets = Elements.assets
	local font = assets.localization.fontGroups.settings
	local c = Elements.currentContainer
	local current_group = Elements.currentGroup

	c:add(
		current_group,
		Slider(assets, {
			label = label,
			font = font.sliders,
			pixelWidth = consts.settingsWidth - consts.tabIndentIndent - consts.tabIndent,
			pixelHeight = consts.sliderHeight,
			sliderPixelWidth = Elements.sliderPixelWidth,
			default_value = default_value,
		}, get_value, on_change, format)
	)
end

Elements.buttonColor = { 0.05, 0.52, 0.65, 1 }

---@param label string
---@param on_change function
function Elements.button(label, on_change)
	if not canAdd(label) then
		return
	end

	local assets = Elements.assets
	local font = assets.localization.fontGroups.settings
	local c = Elements.currentContainer
	local current_group = Elements.currentGroup

	c:add(
		current_group,
		Button(assets, {
			text = label,
			font = font.buttons,
			scale = consts.buttonSize,
			width = consts.buttonWidth,
			color = Elements.buttonColor,
		}, on_change)
	)
end

return Elements
