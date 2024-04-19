local class = require("class")
local flux = require("flux")
local gfx_util = require("gfx_util")

---@class irizz.ScreenTransition
---@operator call: irizz.ScreenTransition
local ScreenTransition = class()

ScreenTransition.percent = 1
ScreenTransition.duration = 0.2

local w, h = 0, 0
local circle_x, circle_y = 0, 0
local shutter_y = 0

---@param cf function
function ScreenTransition:transit(cf)
	if self.coroutine then
		return
	end
	self.coroutine = coroutine.create(function()
		cf()
		self.coroutine = nil
	end)
	assert(coroutine.resume(self.coroutine))
end

function ScreenTransition:animation() end

---@param start_percent number
---@param target_percent number
---@param transition string
function ScreenTransition:transitAsync(start_percent, target_percent, transition)
	w, h = love.graphics.getDimensions()

	local ease = "quadinout"
	self.duration = 0.2

	if transition == "circle" then
		self.animation = self.circle
		circle_x, circle_y = 0, 0

		ease = "quartin"
		if target_percent == 0 then
			circle_x, circle_y = w, h
			ease = "quartout"
		end

		self.duration = 0.4
	elseif transition == "fade" then
		self.animation = self.fade
	elseif transition == "shutter" then
		shutter_y = target_percent == 0 and -h or 0
		self.animation = self.shutter
	end

	self.percent = start_percent
	self.target_percent = target_percent
	flux.to(self, self.duration, { percent = self.target_percent }):ease(ease)
	coroutine.yield()
end

function ScreenTransition:update()
	if self.coroutine and self.target_percent == self.percent then
		assert(coroutine.resume(self.coroutine))
	end
end

local gfx = love.graphics

function ScreenTransition:drawBefore()
	if not self.coroutine then
		return
	end

	gfx.setCanvas({ gfx_util.getCanvas("screenTransition"), stencil = true })
	gfx.clear(0, 0, 0, 1)

	self.isCanvasSet = true
end

function ScreenTransition:shutter()
	gfx.setColor(0, 0, 0, 1)

	local percent = self.target_percent == 0 and 1 - self.percent or self.percent

	gfx.rectangle("fill", 0, shutter_y + (h * percent), w, h)

	gfx.setCanvas()
	gfx.setColor(1, 1, 1, 1)
	gfx.draw(gfx_util.getCanvas("screenTransition"))
end

function ScreenTransition:circle()
	local animationStencil = function()
		gfx.circle("fill", circle_x, circle_y, (w * 1.5) * self.percent)
	end

	gfx.stencil(animationStencil, "replace", 1)
	gfx.setStencilTest("equal", 0)

	gfx.setColor(0, 0, 0, 1)
	gfx.rectangle("fill", 0, 0, w, h)

	gfx.setStencilTest()

	gfx.setCanvas()
	gfx.setColor(1, 1, 1, 1)
	gfx.draw(gfx_util.getCanvas("screenTransition"))
end

function ScreenTransition:fade()
	gfx.setCanvas()
	gfx.setColor(1, 1, 1, self.percent)
	gfx.draw(gfx_util.getCanvas("screenTransition"))
end

function ScreenTransition:drawAfter()
	if not self.isCanvasSet then
		return
	end

	gfx.origin()

	self:animation()

	self.isCanvasSet = false
end

return ScreenTransition
