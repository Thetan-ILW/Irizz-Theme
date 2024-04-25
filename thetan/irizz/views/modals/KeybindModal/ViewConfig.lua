local class = require("class")
local gyatt = require("thetan.gyatt")
local just = require("just")
local Container = require("thetan.gyatt.Container")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textKeybinds
local Font = Theme:getFonts("keybindsModal")
local Layout = require("thetan.irizz.views.modals.KeybindModal.Layout")

local ViewConfig = class()

function ViewConfig:new()
	self.container = Container("keybindsContainer")
end

function ViewConfig:reset()
	self.container:reset()
end

function ViewConfig:keybinds(view)
	local w, h = Layout:move("keybinds")

	local groups = view.keybinds.formattedGroups

	local heightStart = just.height
	gyatt.setSize(w, h)

	Theme:panel(w, h)
	self.container:startDraw(w, h)

	love.graphics.setColor(Color.text)
	for _, groupsKeyValue in ipairs(groups) do
		local _ = groupsKeyValue[1] -- name
		local group = groupsKeyValue[2]
		gyatt.separator()
		love.graphics.setFont(Font.keybinds)
		for _, keyValue in ipairs(group) do
			local description = keyValue[1]
			local bind = keyValue[2]
			gyatt.frame(description, -30, 0, w, h, "right", "top")
			just.text(bind)
			just.next(0, 10)
		end
	end

	self.container.scrollLimit = just.height - heightStart - h
	self.container:stopDraw()

	Theme:border(w, h)
end

function ViewConfig:draw(view)
	Layout:draw()

	local w, h = Layout:move("base")
	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("modalName")
	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.title)
	gyatt.frame(Text.keybinds, 0, 0, w, h, "center", "center")

	self:keybinds(view)
end

return ViewConfig
