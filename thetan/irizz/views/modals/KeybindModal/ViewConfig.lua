local IViewConfig = require("thetan.skibidi.views.IViewConfig")
local Layout = require("thetan.irizz.views.modals.KeybindModal.Layout")

local gyatt = require("thetan.gyatt")
local just = require("just")
local Container = require("thetan.gyatt.Container")

local ui = require("thetan.irizz.ui")
local colors = require("thetan.irizz.ui.colors")

---@type table<string, string>
local text
---@type table<string, love.Font>
local font

local ViewConfig = IViewConfig + {}

function ViewConfig:new(assets)
	self.container = Container("keybindsContainer")

	font = assets.localization.fontGroups.keybindsModal
	text = assets.localization.textGroups.keybindsModal
end

function ViewConfig:reset()
	self.container:reset()
end

function ViewConfig:keybinds(view)
	local w, h = Layout:move("keybinds")

	local groups = view.keybinds.formattedGroups

	local heightStart = just.height

	ui:panel(w, h)
	self.container:startDraw(w, h)

	love.graphics.setColor(colors.ui.text)
	for i, groupsKeyValue in ipairs(groups) do
		local _ = groupsKeyValue[1] -- name
		local group = groupsKeyValue[2]
		love.graphics.setFont(font.keybinds)
		for _, keyValue in ipairs(group) do
			local description = keyValue[1]
			local bind = keyValue[2]
			gyatt.frame(description, -30, 0, w, h, "right", "top")
			gyatt.text(bind)
			just.next(0, 10)
		end

		if i ~= #groups then
			just.next(0, 16)
			love.graphics.rectangle("fill", 0, 0, w - 30, 4)
			just.next(0, 20)
		end
	end

	self.container.scrollLimit = just.height - heightStart - h
	self.container:stopDraw()

	ui:border(w, h)
end

function ViewConfig:draw(view)
	Layout:draw()

	local w, h = Layout:move("modalName")
	love.graphics.setColor(colors.ui.text)
	love.graphics.setFont(font.title)
	gyatt.frame(text.keybinds, 0, 0, w, h, "center", "center")

	self:keybinds(view)
end

return ViewConfig
