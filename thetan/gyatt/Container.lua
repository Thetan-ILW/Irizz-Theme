local class = require("class")

local just = require("just")
local flux = require("flux")
local math_util = require("math_util")

local Container = class()

Container.scrollLimit = math.huge

Container._scroll = 0
Container._scrollTarget = 0
Container._tween = flux.to(Container, 0, { _scroll = 0 })

local name = ""
local xIndent = 15
local yIndent = 5

function Container:new(id)
	name = id
end

function Container:reset()
	self._scroll = 0
	self._scrollTarget = 0
	self._tween:stop()
	just.reset()
end

function Container:startDraw(w, h)
	local delta = just.wheel_over(name, just.is_over(w, h))

	if delta then
		self._scrollTarget = self._scrollTarget + (delta * 80)
		self._scrollTarget = math_util.clamp(-self.scrollLimit - yIndent, self._scrollTarget, 0)
		self._tween = flux.to(self, 0.25, { _scroll = self._scrollTarget }):ease("quartout")
	end

	just.clip(love.graphics.rectangle, "fill", 0, 0, w, h)
	love.graphics.translate(xIndent, self._scroll + yIndent)
end

function Container:stopDraw()
	just.clip()
end

return Container
