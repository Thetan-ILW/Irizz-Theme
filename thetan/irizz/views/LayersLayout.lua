local gfx_util = require("gfx_util")

local Layout = require("sphere.views.Layout")

local _Layout = Layout()

function _Layout:draw()
	local width, height = love.graphics.getDimensions()

	love.graphics.replaceTransform(gfx_util.transform(self.transform))

	local _x, _y = love.graphics.inverseTransformPoint(0, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width, height)

	local _w, _h = _xw - _x, _yh - _y

	local gx, gw = gfx_util.layout(_x, _xw, { 20, "*", 20 })
	local gy, gh = gfx_util.layout(_y, _yh, { 20, "*", 20 })

	self:pack("background", _x, _y, _w, _h)

	local y1, h1 = gfx_util.layout(gy[2], gh[2], { 200, -1, 200 })
	self:pack("uiLockTitle", gx[2], y1[1], gw[2], h1[1])
end

return _Layout
