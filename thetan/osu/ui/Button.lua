local UiElement = require("thetan.osu.ui.UiElement")
local HoverState = require("thetan.osu.ui.HoverState")

local gyatt = require("thetan.gyatt")
local ui = require("thetan.osu.ui")

---@class osu.ui.Button : osu.UiElement
---@operator call: osu.ui.Button
---@field label love.Text
---@field scale number
---@field width number
---@field color number[]
---@field margin number
---@field private onChange function
---@field private totalW number
---@field private totalH number
---@field private middleAdditionalScale number
---@field private imageLeft love.Image
---@field private imageMiddle love.Image
---@field private imageRight love.Image
---@field private hover boolean
---@field private hoverUpdateTime number
---@field private brightenShader love.Shader
---@field private hoverState osu.ui.HoverState
---@field private animation number
local Button = UiElement + {}

---@param assets osu.OsuAssets
---@param params { text: string, font: love.Font, scale: number?, width: number?, color: number[]?, margin: number? }
---@param on_change function
function Button:new(assets, params, on_change)
	self.assets = assets

	local img = assets.images
	self.imageLeft = img.buttonLeft
	self.imageMiddle = img.buttonMiddle
	self.imageRight = img.buttonRight

	self.label = love.graphics.newText(params.font, params.text)
	self.scale = params.scale or 1
	self.width = params.width or 1
	self.color = params.color or { 1, 1, 1, 1 }
	self.margin = params.margin or 15

	self.middleAdditionalScale = 283 / (self.imageMiddle:getPixelWidth() / self.imageMiddle:getDPIScale())

	self.totalW = self.imageLeft:getWidth() * self.scale
		+ self.imageMiddle:getWidth() * self.scale * self.width * self.middleAdditionalScale
		+ self.imageRight:getWidth() * self.scale

	self.totalH = self.imageLeft:getHeight() * self.scale + self.margin

	self.hover = false
	self.hoverUpdateTime = -math.huge

	self.brightenShader = require("irizz.shaders").brighten
	self.onChange = on_change

	self.hoverState = HoverState("linear", 0.2)
	self.animation = 0
end

---@return number
---@return number
function Button:getDimensions()
	return self.totalW, self.totalH
end

local gfx = love.graphics

---@param has_focus boolean
function Button:update(has_focus)
	self.hover, self.animation = self.hoverState:check(self.totalW, self.totalH)

	if self.hover and gyatt.mousePressed(1) and has_focus then
		self.onChange()
		self.changeTime = -math.huge
	end
end

function Button:draw()
	local left = self.imageLeft
	local middle = self.imageMiddle
	local right = self.imageRight
	local scale = self.scale

	local prev_shader = gfx.getShader()

	gfx.setShader(self.brightenShader)

	local a = self.animation * 0.3

	self.brightenShader:send("amount", a)

	gfx.setColor(self.color)

	gfx.push()
	gfx.translate(0, self.margin / 2)
	gfx.draw(left, 0, 0, 0, scale, scale)
	gfx.translate(left:getWidth() * scale, 0)
	gfx.draw(middle, 0, 0, 0, scale * self.width * self.middleAdditionalScale, scale)
	gfx.translate(middle:getWidth() * scale * self.width * self.middleAdditionalScale, 0)
	gfx.draw(right, 0, 0, 0, scale, scale)
	gfx.pop()

	gfx.setShader(prev_shader)

	gfx.push()
	gfx.setColor({ 1, 1, 1, 1 })
	ui.textFrameShadow(self.label, 0, 0, self.totalW, self.totalH, "center", "center")
	gfx.pop()

	gyatt.next(0, self.totalH)
end

return Button
