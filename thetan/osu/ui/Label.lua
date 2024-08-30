local UiElement = require("thetan.osu.ui.UiElement")

local gyatt = require("thetan.gyatt")

---@class osu.ui.Label : osu.UiElement
---@operator call: osu.ui.Label
---@field label love.Text
---@field color number[]
---@field align "left" | "center" | "right"
---@field private totalW number
---@field private totalH number
---@field private hover boolean
---@field private onChange function?
local Label = UiElement + {}

---@param assets osu.OsuAssets
---@param params { text: string, font: love.Font, color: number[]?, pixelWidth: number, pixelHeight: number?, align?: "left" | "center" | "right" }
---@param on_change function?
function Label:new(assets, params, on_change)
	self.assets = assets
	self.label = love.graphics.newText(params.font, params.text)
	self.color = params.color or { 1, 1, 1, 1 }
	self.align = params.align or "center"

	self.totalW = params.pixelWidth
	self.onChange = on_change

	if params.pixelHeight then
		self.totalH = params.pixelHeight
		return
	end

	self.totalH = self.label:getHeight() * math.min(gyatt.getTextScale(), 1)
end

local gfx = love.graphics

function Label:update()
	self.hover = gyatt.isOver(self.totalW, self.totalH)

	if self.hover and gyatt.mousePressed(1) then
		if self.onChange then
			self.onChange()
			self.changeTime = -math.huge
		end
	end
end

function Label:draw()
	gfx.setColor(self.color)
	gyatt.textFrame(self.label, 0, 0, self.totalW, self.totalH, self.align, "center")
	gfx.translate(0, self.totalH)
end

return Label
