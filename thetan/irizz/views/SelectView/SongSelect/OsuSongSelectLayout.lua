local gfx_util = require("gfx_util")

local Layout = require("sphere.views.Layout")

local _Layout = Layout()

_Layout.transform = { { 1 / 2, -16 / 9 / 2 }, 0, 0, { 0, 1 / 768 }, { 0, 1 / 768 }, 0, 0, 0, 0 }

function _Layout:draw()
	local width, height = love.graphics.getDimensions()

	love.graphics.replaceTransform(gfx_util.transform(self.transform))

	local _x, _y = love.graphics.inverseTransformPoint(0, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width, height)

	local _w, _h = _xw - _x, _yh - _y

	self:pack("base", _x, _y, _w, _h)

	local x1, w1 = gfx_util.layout(_x, _w, { 224, -1 })
	local y1, h1 = gfx_util.layout(_y, _h, { 678, -1 })

	self:pack("bottomButtons", x1[2], y1[2], w1[2], h1[2])
end

return _Layout
