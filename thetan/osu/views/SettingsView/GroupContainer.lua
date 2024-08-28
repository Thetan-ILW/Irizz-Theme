local class = require("class")

local consts = require("thetan.osu.views.SettingsView.Consts")
local gyatt = require("thetan.gyatt")

local Label = require("thetan.osu.ui.Label")

---@class osu.SettingsView.GroupContainer
---@operator call: osu.SettingsView.GroupContainer
---@field groups table<string, {name: string, height: number, elements: osu.UiElement[]}>
---@field groupOrder string[]
---@field elementsHeight number
---@field position number
---@field height number
---@field hoverPosition number
---@field hoverSize number
---@field tabLabel osu.ui.Label
---@field isEmpty boolean
---@field openCombo osu.ui.Combo?
local GroupContainer = class()

---@type table<string, love.Font>
local font

---@param name string
---@param fonts table<string, love.Font>
function GroupContainer:new(name, fonts)
	font = fonts
	self.groups = {}
	self.groupOrder = {}
	self.elementsHeight = 0
	self.position = 0
	self.height = 0
	self.hoverPosition = 0
	self.hoverSize = 0
	self.isEmpty = true
	self.openComboPosition = 0

	self.tabLabel = Label({
		text = name,
		width = 438 - 24 - 20,
		font = fonts.tabLabel,
		color = { 0.51, 0.78, 0.88, 1 },
		align = "right",
	})
end

function GroupContainer:clear()
	self.groups = {}
	self.groupOrder = {}
end

function GroupContainer:createGroup(id, name)
	self.groups[id] = {
		name = name,
		height = 0,
		elements = {},
	}

	table.insert(self.groupOrder, id)
end

function GroupContainer:removeEmptyGroups()
	for i, id in ipairs(self.groupOrder) do
		if #self.groups[id].elements == 0 then
			table.remove(self.groupOrder, i)
			self.groups[id] = nil
		end
	end
end

function GroupContainer:updateHeight()
	local group_count = #self.groupOrder
	local ts = math.min(gyatt.getTextScale(), 1)
	local tab_label = font.tabLabel:getHeight() * ts + consts.tabLabelSpacing
	local group_labels = (font.groupLabel:getHeight() * ts + consts.groupLabelSpacing) * group_count
	local spacing = (group_count - 1) * consts.groupSpacing

	self.height = tab_label + group_labels + spacing + self.elementsHeight + consts.containerSpacing
end

---@param element osu.UiElement
function GroupContainer:add(group, element)
	self.isEmpty = false
	table.insert(self.groups[group].elements, element)

	local h = element:getHeight()
	self.elementsHeight = self.elementsHeight + h
	self.groups[group].height = self.groups[group].height + h
end

local gfx = love.graphics

function GroupContainer:draw()
	gfx.translate(consts.tabIndent, 0)

	self.hoverPosition = 0
	self.hoverSize = 0

	gfx.translate(0, consts.containerSpacing)
	self.tabLabel:update()
	self.tabLabel:draw()
	gfx.translate(0, consts.tabLabelSpacing)
	local current_position = self.tabLabel:getHeight() + consts.tabLabelSpacing + consts.containerSpacing

	self.openCombo = nil

	for _, id in ipairs(self.groupOrder) do
		local group = self.groups[id]

		gfx.setColor(1, 1, 1, 0.2)
		gfx.rectangle(
			"fill",
			0,
			0,
			5,
			group.height + font.groupLabel:getHeight() * gyatt.getTextScale() + consts.groupLabelSpacing
		)

		gfx.translate(consts.tabIndentIndent, 0)

		gfx.setColor(1, 1, 1)
		gfx.setFont(font.groupLabel)
		gyatt.text(group.name)

		gfx.translate(0, consts.groupLabelSpacing)
		current_position = current_position
			+ (font.groupLabel:getHeight() * gyatt.getTextScale())
			+ consts.groupLabelSpacing

		for _, element in ipairs(group.elements) do
			if not self.openCombo or not self.openCombo:isFocused() then
				element:update()
			end

			if element.state and element.state ~= "hidden" then
				gfx.push()
				---@cast element osu.ui.Combo
				self.openCombo = element
			end

			element:draw()

			if element:isMouseOver() then
				self.hoverPosition = current_position
				self.hoverSize = element:getHeight()
			end

			current_position = current_position + element:getHeight()
		end

		gfx.translate(-consts.tabIndentIndent, consts.groupSpacing)
		current_position = current_position + consts.groupSpacing
	end

	gfx.translate(-consts.tabIndent, -consts.groupSpacing)
end

return GroupContainer
