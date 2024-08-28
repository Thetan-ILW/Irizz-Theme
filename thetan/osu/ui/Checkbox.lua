local UiElement = require("thetan.osu.ui.UiElement")

local gyatt = require("thetan.gyatt")
local math_util = require("math_util")

---@class osu.ui.Checkbox : osu.UiElement
---@operator call: osu.ui.Checkbox
---@field text string
---@field font love.Font
---@field private totalW number
---@field private totalH number
---@field private hover boolean
---@field private imgOn love.Image
---@field private imgOff love.Image
---@field private getValue function
---@field private onChange function
---@field private imageScale number
---@field private toggled boolean
---@field private toggleTime number
local Checkbox = UiElement + {}

---@param assets osu.OsuAssets
---@param params { text: string, font: love.Font, pixelWidth: number, pixelHeight: number }
---@param get_value function
---@param on_change function
function Checkbox:new(assets, params, get_value, on_change)
	self.text = params.text
	self.font = params.font
	self.totalW = params.pixelWidth
	self.totalH = params.pixelHeight
	self.getValue = get_value
	self.onChange = on_change

	self.imgOn = assets.images.checkboxOn
	self.imgOff = assets.images.checkboxOff
	local ih = self.imgOff:getHeight()
	self.imageScale = self.totalH / ih

	self.toggleTime = -math.huge
end

function Checkbox:update()
	self.toggled = self.getValue()

	self.hover = gyatt.isOver(self.totalW, self.totalH)

	if self.hover and gyatt.mousePressed(1) then
		self.onChange()
		self.toggleTime = love.timer.getTime()
	end
end

local gfx = love.graphics

function Checkbox:draw()
	gfx.setColor(1, 1, 1)
	gfx.setFont(self.font)

	local scale = 0.5 + (math_util.clamp(love.timer.getTime() - self.toggleTime, 0, 0.1) * 10) * 0.5
	local image_size = self.imgOn:getHeight() * self.imageScale
	local x = image_size / 2 - (image_size * scale) / 2

	if self.toggled then
		gfx.draw(self.imgOn, x, x, 0, self.imageScale * scale, self.imageScale * scale)
	else
		gfx.draw(self.imgOff, x, x, 0, self.imageScale * scale, self.imageScale * scale)
	end

	local x = self.imgOff:getWidth()
	gyatt.frame(self.text, x * self.imageScale, 0, self.totalW, self.totalH, "left", "center")
	gfx.translate(0, self.totalH)
end

return Checkbox
