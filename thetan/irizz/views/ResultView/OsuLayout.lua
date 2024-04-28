local gfx_util = require("gfx_util")

local Layout = require("sphere.views.Layout")

local _Layout = Layout()

function _Layout:draw()
	local width, height = love.graphics.getDimensions()

	love.graphics.replaceTransform(gfx_util.transform(self.transform))

	local _x, _y = love.graphics.inverseTransformPoint(0, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width, height)

	local _w, _h = _xw - _x, _yh - _y

	local y1, h1 = gfx_util.layout(_y, _yh, { 150, 720, 200, 14 })

	self:pack("title", _x, y1[1], _w, h1[1])
	self:pack("panel", _x, y1[2], _w, h1[2])

	local x1, w1 = gfx_util.layout(_x, _w, { 364, 435, -1 })

	self:pack("hitGraph", x1[2], y1[3], w1[2], h1[3])
end

return _Layout
