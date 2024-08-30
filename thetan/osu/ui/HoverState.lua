local class = require("class")

local gyatt = require("thetan.gyatt")
local flux = require("flux")

---@class osu.ui.HoverState
---@operator call: osu.ui.HoverState
---@field state "idle" | "fade_in" | "fade_out" | "visible"
---@field alpha number
---@field ease string
---@field tweenDuration number
---@field tween table?
local HoverState = class()

---@param ease string
---@param tween_duration number
function HoverState:new(ease, tween_duration)
	self.ease = ease
	self.tweenDuration = tween_duration
	self.state = "idle"
	self.alpha = 0
end

function HoverState:fadeIn()
	if self.tween then
		self.tween:stop()
	end
	self.tween = flux.to(self, self.tweenDuration, { alpha = 1 }):ease(self.ease)
	self.state = "fade_in"
end

function HoverState:fadeOut()
	if self.tween then
		self.tween:stop()
	end
	self.tween = flux.to(self, self.tweenDuration, { alpha = 0 }):ease(self.ease)
	self.state = "fade_out"
end

---@param w number
---@param h number
---@param x number?
---@param y number?
---@return boolean
---@return number
function HoverState:check(w, h, x, y)
	local over = gyatt.isOver(w, h, x or 0, y or 0)
	local state = self.state

	if state == "idle" then
		if over then
			self:fadeIn()
		end
	elseif state == "fade_in" then
		if self.alpha == 1 then
			self.state = "visible"
		end
		if not over then
			self:fadeOut()
		end
	elseif state == "visible" then
		if not over then
			self:fadeOut()
		end
	elseif state == "fade_out" then
		if self.alpha == 0 then
			self.state = "idle"
		end
		if over then
			self:fadeIn()
		end
	end

	return over, self.alpha
end

return HoverState
