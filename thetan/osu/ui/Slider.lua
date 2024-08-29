local UiElement = require("thetan.osu.ui.UiElement")

local math_util = require("math_util")
local gyatt = require("thetan.gyatt")

---@class osu.ui.Slider : osu.UiElement
---@operator call: osu.ui.Slider
---@field private label string
---@field private font love.Font
---@field private sliderW number?
---@field private params { min: number, max: number, increment: number }
---@field private value number
---@field private dragging boolean
---@field private getValue fun(): number, { min: number, max: number, increment: number }
---@field private onChange fun(number)
local Slider = UiElement + {}

---@param params { label: string, font: love.Font, pixelWidth: number, pixelHeight: number, sliderPixelWidth: number?, defaultValue: number }
---@param get_value fun(): number
---@param on_change fun(number)
function Slider:new(assets, params, get_value, on_change)
	self.assets = assets
	self.label = params.label
	self.font = params.font
	self.totalW = params.pixelWidth
	self.totalH = params.pixelHeight
	self.sliderW = params.sliderPixelWidth
	self.defaultValue = params.defaultValue
	self.dragging = false
	self.getValue = get_value
	self.onChange = on_change
end

local gfx = love.graphics
local line_height = 1
local head_radius = 8
local text_indent = 15

function Slider:getPosAndWidth()
	if self.sliderW then
		local w = self.sliderW
		local x = self.totalW - w - 15
		return x, w
	end

	local x = self.font:getWidth(self.label) * gyatt.getTextScale()
	local w = self.totalW - x - 15 - text_indent

	return x, w
end

function Slider:update(has_focus)
	self.value, self.params = self.getValue()

	if self.defaultValue ~= nil then
		self.valueChanged = self.defaultValue ~= self.value
	end

	self.hover = gyatt.isOver(self.totalW, self.totalH) and has_focus

	local x, w = self:getPosAndWidth()

	local over_slider = gyatt.isOver(w + 8, self.totalH, x - 4, 0)

	if over_slider then
		if gyatt.mousePressed(1) then
			self.dragging = true
		end
	end

	if self.dragging then
		local mx, _ = gfx.inverseTransformPoint(love.mouse.getPosition())

		if love.mouse.isDown(1) then
			local range = self.params.max - self.params.min
			local percent = self.params.min + ((mx - x) / w) * range
			local value = math_util.clamp(percent, self.params.min, self.params.max)

			self.onChange(math_util.round(value, self.params.increment))
			self.changeTime = -math.huge
		else
			self.dragging = false
		end
	end
end

function Slider:draw()
	gfx.setColor(1, 1, 1)
	gfx.setFont(self.font)
	gyatt.frame(self.label, 0, 0, self.totalW, self.totalH, "left", "center")

	local x, w = self:getPosAndWidth()

	local r2 = head_radius * 2
	local head_coordinate = (self.value - self.params.min) / (self.params.max - self.params.min)
	local head_x = head_coordinate * (w - r2)

	gfx.push()
	gfx.translate(x + text_indent, self.totalH / 2 - line_height)

	gfx.setColor(0.89, 0.47, 0.56)
	gfx.rectangle("fill", 0, 0, math.max(head_x - head_radius, 0), line_height)
	gfx.setColor(0.89, 0.47, 0.56, 0.6)
	gfx.rectangle("fill", head_x + head_radius, 0, w - head_x - r2, line_height)

	gfx.setColor(0.89, 0.47, 0.56)
	gfx.setLineWidth(1)
	gfx.circle("line", head_x, 0, head_radius)

	gfx.pop()
	gfx.translate(0, self.totalH)
end

return Slider
