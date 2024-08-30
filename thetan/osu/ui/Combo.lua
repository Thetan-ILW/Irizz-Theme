local UiElement = require("thetan.osu.ui.UiElement")
local gyatt = require("thetan.gyatt")
local flux = require("flux")
local HoverState = require("thetan.osu.ui.HoverState")

---@class osu.ui.Combo : osu.UiElement
---@operator call: osu.ui.Combo
---@field label love.Text
---@field font love.Font
---@field labelColor number[]
---@field hoverColor number[]
---@field borderColor number[]
---@field private defaultValue any?
---@field private valueChanged boolean
---@field private totalW number
---@field private totalH number
---@field private hover boolean
---@field private hoverIndex integer
---@field private onChange function
---@field private getValue fun(): any, table
---@field private format? fun(any): string
---@field private selected string
---@field private items any[]
---@field private icon love.Image
---@field private state "hidden" | "fade_in" | "open" | "fade_out"
---@field private visibility number
---@field private visibilityTween table?
---@field private headHoverState osu.ui.HoverState
---@field private headAnimation number
local Combo = UiElement + {}

---@param assets osu.OsuAssets
---@param params { label: string, font: love.Font, pixelWidth: number, pixelHeight: number, hoverColor: number[]?, borderColor: number[]?, defaultValue: any? }
---@param get_value function
---@param on_change function
---@param format function?
function Combo:new(assets, params, get_value, on_change, format)
	self.assets = assets
	self.label = love.graphics.newText(params.font, params.label)
	self.font = params.font
	self.totalW = params.pixelWidth
	self.totalH = params.pixelHeight
	self.hoverColor = params.hoverColor or { 0.72, 0.06, 0.46, 1 }
	self.borderColor = params.borderColor or { 0, 0, 0, 1 }
	self.defaultValue = params.defaultValue
	self.valueChanged = false
	self.onChange = on_change
	self.getValue = get_value
	self.format = format
	self.selected = "! broken getValue() !"
	self.icon = assets.images.dropdownArrow
	self.state = "hidden"
	self.visibility = 0
	self.changeTime = -math.huge
	self.headHoverState = HoverState("quadout", 0.12)
	self.headAnimation = 0
end

local gfx = love.graphics

---@private
function Combo:open()
	if self.visibilityTween then
		self.visibilityTween:stop()
	end
	self.visibilityTween = flux.to(self, 0.35, { visibility = 1 }):ease("cubicout")
	self.state = "fade_in"
end

---@private
function Combo:close()
	if self.visibilityTween then
		self.visibilityTween:stop()
	end
	self.visibilityTween = flux.to(self, 0.35, { visibility = 0 }):ease("cubicout")
	self.state = "fade_out"
end

---@param event? "open" | "close" | "toggle"
function Combo:processState(event)
	local state = self.state

	if event == "toggle" then
		event = (state == "open" or state == "fade_in") and "close" or "open"
	end

	if state == "hidden" then
		if event == "open" then
			self:open()
		end
	elseif state == "fade_in" then
		if self.visibility == 1 then
			self.state = "open"
		end
		if event == "close" then
			self:close()
		end
	elseif state == "open" then
		if event == "close" then
			self:close()
		end
	elseif state == "fade_out" then
		if self.visibility == 0 then
			self.state = "hidden"
		end
		if event == "open" then
			self:open()
		end
	end
end

function Combo:update(has_focus)
	self:processState()
	local selected, items = self.getValue()
	self.selected = self.format and self.format(selected) or tostring(selected)
	self.items = items
	self.hover, self.headAnimation = self.headHoverState:check(self.totalW, self.totalH)
	self.hover = self.hover and has_focus

	self.hoverColor[4] = self.headAnimation

	if self.defaultValue ~= nil then
		self.valueChanged = selected ~= self.defaultValue
	end

	self.hoverIndex = 0

	if self.state ~= "hidden" then
		local x = self.label:getWidth() * math.min(gyatt.getTextScale(), 1)
		local w = self.totalW - x - 24
		local h = math.floor(self.totalH / 1.5)

		for i, _ in ipairs(self.items) do
			self.hoverIndex = gyatt.isOver(w, h, x, (self.totalH - h) + h * i) and i or self.hoverIndex
		end

		if self.hoverIndex ~= 0 and gyatt.mousePressed(1) then
			self.onChange(self.items[self.hoverIndex])
			self.changeTime = love.timer.getTime()
			gyatt.resetJust()
			self:processState("close")
		end
	end

	if self.hover and gyatt.mousePressed(1) then
		self:processState("toggle")
	elseif not self.hover and gyatt.mousePressed(1) then
		self:processState("close")
	end
end

function Combo:isFocused()
	return self.hoverIndex ~= 0
end

local black = { 0, 0, 0, 1 }

function Combo:draw()
	gfx.setColor(1, 1, 1)
	gyatt.textFrame(self.label, 0, 0, self.totalW, self.totalH, "left", "center")
	self:drawHead()
end

function Combo:drawHead()
	gfx.setFont(self.font)
	gfx.push()
	local x = self.label:getWidth() * math.min(gyatt.getTextScale(), 1)
	gfx.translate(x + 12, 0)

	local w = self.totalW - x - 24
	local h = math.floor(self.totalH / 1.5)
	local y = self.totalH / 2 - h / 2

	gfx.setColor(self.hover and self.hoverColor or black)
	gfx.setLineWidth(2)
	gfx.rectangle("fill", 0, y, w, h, 4)

	gfx.setColor(self.hover and self.hoverColor or self.borderColor)
	gfx.rectangle("line", 0, y, w, h, 4)

	gfx.setColor(1, 1, 1)
	gyatt.frame(self.selected, 2, y, w, h, "left", "center")

	y = self.totalH / 2 - self.icon:getHeight() / 2
	gfx.translate(w - 25, y)
	gfx.draw(self.icon)

	gfx.pop()

	gfx.translate(0, self.totalH)
end

function Combo:drawBody()
	gfx.setFont(self.font)
	gfx.push()
	local x = self.label:getWidth() * math.min(gyatt.getTextScale(), 1)
	local w = self.totalW - x - 24
	local h = math.floor(self.totalH / 1.5)
	gfx.translate(x + 12, (self.totalH - h) / 2 + 2)

	for i, v in ipairs(self.items) do
		gfx.translate(0, h * self.visibility)
		local color = self.hoverIndex == i and self.hoverColor or black
		gfx.setColor(color[1], color[2], color[3], self.visibility)
		gfx.rectangle("fill", 0, 0, w, h, 4)
		gfx.setColor(1, 1, 1, self.visibility)
		gyatt.frame(self.format and self.format(v) or tostring(v), 2, 0, w, h, "left", "center")
	end
	gfx.pop()

	self:drawHead()
end

return Combo
