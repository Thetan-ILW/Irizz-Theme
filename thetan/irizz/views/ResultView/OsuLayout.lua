local gfx_util = require("gfx_util")

local Layout = require("sphere.views.Layout")

local _Layout = Layout()

_Layout.transform = { { 1 / 2, -16 / 9 / 2 }, 0, 0, { 0, 1 / 768 }, { 0, 1 / 768 }, 0, 0, 0, 0 }

function _Layout:draw()
	love.graphics.replaceTransform(gfx_util.transform(self.transform))

	local width, height = love.graphics.getDimensions()
	local _x, _y = love.graphics.inverseTransformPoint(0, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width, height)

	local _w, _h = _xw - _x, _yh - _y

	local y1, h1 = gfx_util.layout(_y, _h, { 96, 6, 500, 6, 160 })

	self:pack("title", _x, y1[1], _w, h1[1])
	self:pack("panel", _x, y1[3], _w, h1[3])

	local x1, w1 = gfx_util.layout(_x, _w, { 256, 311, -1 })

	self:pack("hitGraph", x1[2], y1[5], w1[2], h1[5])

	local x2, w2 = gfx_util.layout(_x, _w, { 1171, -1 })
	local y2, h2 = gfx_util.layout(_y, _h, { 316, -1 })
	self:pack("grade", x2[2], y2[2], w2[2], h2[2])

	local x3, w3 = gfx_util.layout(_x, _w, { 197, 309, -1 })
	local y3, h3 = gfx_util.layout(_y, _h, { 127, 46, -1 })

	self:pack("score", x3[2], y3[2], w3[2], h3[2])

	local x4, w4 = gfx_util.layout(_x, _w, { 130, 130, 189, 130, -1 })
	local y4, h4 = gfx_util.layout(_y, _h, { 228, 45, 51, 45, 51, 45, 61, 51, -1 })

	self:pack("column2", x4[2], 0, w4[2], 0)
	self:pack("column4", x4[4], 0, w4[4], 0)
	self:pack("row1", 0, y4[2], 0, h4[2])
	self:pack("row2", 0, y4[4], 0, h4[4])
	self:pack("row3", 0, y4[6], 0, h4[6])

	local x5, w5 = gfx_util.layout(_x, _w, { 26, 130, 155, 130, -1 })
	self:pack("combo", x5[2], y4[8], w5[2], h4[8])
	self:pack("accuracy", x5[4], y4[8], w5[4], h4[8])
end

return _Layout
