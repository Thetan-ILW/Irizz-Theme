local UiElement = require("thetan.osu.ui.UiElement")

local gyatt = require("thetan.gyatt")

---@class osu.ui.Label : osu.UiElement
---@operator call: osu.ui.Label
---@field text string
---@field font love.Font
---@field color number[]
---@field align "left" | "center" | "right"
---@field private totalW number
---@field private totalH number
local Label = UiElement + {}

---@param params { text: string, font: love.Font, color: number[]?, width: number, align?: "left" | "center" | "right" }
function Label:new(params)
	self.text = params.text
	self.font = params.font
	self.color = params.color or { 1, 1, 1, 1 }
	self.align = params.align or "center"

	self.totalW = params.width
	self.totalH = self.font:getHeight() * gyatt.getTextScale()
end

local gfx = love.graphics

function Label:update()
	self.totalH = self.font:getHeight() * gyatt.getTextScale()
end

function Label:draw()
	gfx.setColor(self.color)
	gfx.setFont(self.font)
	gyatt.text(self.text, self.totalW, self.align)
end

return Label
