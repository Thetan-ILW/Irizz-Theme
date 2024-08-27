local class = require("class")

local gyatt = require("thetan.gyatt")

---@class osu.SettingsView.GroupContainer
---@operator call: osu.SettingsView.GroupContainer
---@field groups table<string, {name: string, height: number, elements: osu.UiElement[]}>
---@field groupOrder string[]
---@field height number
---@field position number
---@field hoverPosition number
---@field hoverSize number
local GroupContainer = class()

---@type table<string, love.Font>
local font

local group_label_spacing = 15
local group_spacing = 40

---@param fonts table<string, love.Font>
function GroupContainer:new(fonts)
	font = fonts
	self.groups = {}
	self.groupOrder = {}
	self.height = 0
	self.position = 0
	self.hoverPosition = 0
	self.hoverSize = 0
end

function GroupContainer:clear()
	self.groups = {}
	self.groupOrder = {}
end

function GroupContainer:createGroup(id, name)
	self.groups[id] = {
		name = name,
		height = font.groupLabel:getHeight() + group_label_spacing,
		elements = {},
	}

	table.insert(self.groupOrder, id)
end

---@param element osu.UiElement
function GroupContainer:add(group, element)
	table.insert(self.groups[group].elements, element)

	local h = element:getHeight()
	self.height = self.height + h
	self.groups[group].height = self.groups[group].height + h
end

local gfx = love.graphics

function GroupContainer:draw()
	gfx.translate(24, self.position)
	local current_position = 0

	self.hoverSize = 0

	for _, id in ipairs(self.groupOrder) do
		local group = self.groups[id]

		gfx.setColor(1, 1, 1, 0.2)
		gfx.rectangle("fill", 0, 0, 5, group.height)
		gfx.translate(10, 0)

		gfx.setColor(1, 1, 1)
		gfx.setFont(font.groupLabel)
		gyatt.text(group.name)

		gfx.translate(0, group_label_spacing)
		current_position = current_position + font.groupLabel:getHeight() + group_label_spacing

		for _, element in ipairs(group.elements) do
			element:update()
			element:draw()

			if element:isMouseOver() then
				self.hoverPosition = current_position
				self.hoverSize = element:getHeight()
			end

			current_position = current_position + element:getHeight()
		end

		gfx.translate(-10, group_spacing)
		current_position = current_position + group_spacing
	end
end

return GroupContainer
