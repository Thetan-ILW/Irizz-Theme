local gfx_util = require("gfx_util")

local Layout = require("sphere.views.Layout")

local _Layout = Layout()

function _Layout:draw()
	local width, height = love.graphics.getDimensions()

	love.graphics.replaceTransform(gfx_util.transform(self.transform))

	local _x, _y = love.graphics.inverseTransformPoint(0, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width, height)

	local _w, _h = _xw - _x, _yh - _y

	self:pack("base", _x, _y, _w, _h)

	local gx, gw = gfx_util.layout(_x, _xw, { 20, "*", 20 })
	local gy, gh = gfx_util.layout(_y, _yh, { 20, "*", 20 })

	local y1, h1 = gfx_util.layout(gy[2], gh[2], { -0.5, 300, 300, 300, -0.5 })

	self:pack("modalName", gx[2], y1[2], gw[2], h1[2])
	self:pack("list", gx[2], y1[3], gw[2], h1[3])
	self:pack("buttons", gx[2], y1[4], gw[2], h1[4])
end

return _Layout
