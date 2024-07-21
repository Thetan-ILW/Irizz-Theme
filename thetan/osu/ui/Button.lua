local class = require("class")

local gyatt = require("thetan.gyatt")
local ui = require("thetan.osu.ui")

---@class osu.ui.Button
---@operator call: osu.ui.Button
---@field text string
---@field font love.Font
---@field scale number
---@field width number
---@field color number[]
---@field spacing number
---@field private totalW number
---@field private totalH number
---@field private imageLeft love.Image
---@field private imageMiddle love.Image
---@field private imageRight love.Image
---@field private hover boolean
---@field private hoverUpdateTime number
---@field private brightenShader love.Shader
local Button = class()

---@param assets osu.OsuSelectAssets
---@param params { text: string, font: love.Font, scale: number, width: number, color: number[], spacing: number }
function Button:new(assets, params)
	local img = assets.images
	self.imageLeft = img.buttonLeft
	self.imageMiddle = img.buttonMiddle
	self.imageRight = img.buttonRight

	self.text = params.text
	self.font = params.font
	self.scale = params.scale or 1
	self.width = params.width or 1
	self.color = params.color or { 1, 1, 1, 1 }
	self.spacing = params.spacing or 15

	self.totalW = self.imageLeft:getWidth() * self.scale
		+ self.imageMiddle:getWidth() * self.scale * self.width
		+ self.imageRight:getWidth() * self.scale

	self.totalH = self.imageLeft:getHeight() * self.scale

	self.hover = false
	self.hoverUpdateTime = -math.huge

	self.brightenShader = require("irizz.shaders").brighten
end

---@return number
---@return number
function Button:getDimensions()
	return self.totalW, self.totalH
end

local gfx = love.graphics

---@return boolean
function Button:update()
	local mouse_over = gyatt.isOver(self.totalW, self.totalH)

	if (not self.hover and mouse_over) or (self.hover and not mouse_over) then
		self.hoverUpdateTime = love.timer.getTime()
	end

	self.hover = mouse_over

	if mouse_over and gyatt.mousePressed(1) then
		return true
	end

	return false
end

---@return boolean
function Button:draw()
	local left = self.imageLeft
	local middle = self.imageMiddle
	local right = self.imageRight
	local scale = self.scale

	local pressed = self:update()

	local prev_shader = gfx.getShader()

	gfx.setShader(self.brightenShader)

	local a = gyatt.easeOutCubic(self.hoverUpdateTime, 0.2) * 0.3

	if not self.hover then
		a = 0.3 - a
	end

	self.brightenShader:send("amount", a)

	gfx.setColor(self.color)

	gfx.push()
	gfx.draw(left, 0, 0, 0, scale, scale)
	gfx.translate(left:getWidth() * scale, 0)
	gfx.draw(middle, 0, 0, 0, scale * self.width, scale)
	gfx.translate(middle:getWidth() * scale * self.width, 0)
	gfx.draw(right, 0, 0, 0, scale, scale)
	gfx.pop()

	gfx.setShader(prev_shader)

	gfx.setFont(self.font)
	gfx.setColor({ 1, 1, 1, 1 })
	ui.frameWithShadow(self.text, 0, 0, self.totalW, self.totalH, "center", "center")

	gyatt.next(0, self.totalH + self.spacing)

	return pressed
end

return Button
