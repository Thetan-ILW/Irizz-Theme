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
---@param has_focus boolean?
---@return boolean
---@return number
---@return boolean
function HoverState:check(w, h, x, y, has_focus)
	has_focus = has_focus == nil and true or has_focus
	---@cast has_focus boolean
	local over = gyatt.isOver(w, h, x or 0, y or 0) and has_focus
	local just_hovered = false
	local state = self.state

	if state == "idle" then
		if over then
			self:fadeIn()
			just_hovered = true
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
			just_hovered = true
		end
	end

	return over, self.alpha, just_hovered
end

return HoverState
