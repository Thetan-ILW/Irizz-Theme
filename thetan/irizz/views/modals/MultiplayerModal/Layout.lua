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

	local x1, w1 = gfx_util.layout(gx[2], gw[2], { -0.5, 250, 30, 450, 30, 250, -0.5 })
	local y1, h1 = gfx_util.layout(gy[2], gh[2], { 200, -1, 200 })

	local x2, w2 = gfx_util.layout(gx[2], gw[2], {-0.5, 700, -0.5})
	local y2, h2 = gfx_util.layout(gy[2], gh[2], {-0.5, 200, -0.5})

	local y3, h3 = gfx_util.layout(y1[2], h1[2], {-0.05, -0.9, -0.05})
	local y4, h4 = gfx_util.layout(y1[2], h1[2], {-0.05, -0.4, -0.55})

	self:pack("modalName", gx[2], y1[1], gw[2], h1[1])
	self:pack("players", x1[2], y3[2], w1[2], h3[2])
	self:pack("rooms", x1[4], y1[2], w1[4], h1[2])
	self:pack("buttons", x1[6], y4[2], w1[6], h4[2])
	self:pack("connectScreen", x2[2], y2[2], w2[2], h2[2])
end

return _Layout
