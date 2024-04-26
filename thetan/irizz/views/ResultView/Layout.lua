local gfx_util = require("gfx_util")

local Layout = require("sphere.views.Layout")

local _Layout = Layout()

local outerPanelsSize = 350
local innerPanelSize = 300
local gap = 20

function _Layout:draw()
	local width, height = love.graphics.getDimensions()

	love.graphics.replaceTransform(gfx_util.transform(self.transform))

	local _x, _y = love.graphics.inverseTransformPoint(0, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width, height)

	local gx, gw = gfx_util.layout(_x, _xw, { gap, "*", gap })
	local gy, gh = gfx_util.layout(_y, _yh, { 100, -1, gap })

	local _w, _h = _xw - _x, _yh - _y

	local y1, h1 = gfx_util.layout(gy[2], gh[2], { -0.05, -0.05, -0.05, -0.05, -0.65, -0.05 })

	self:pack("title", gx[2], y1[1], gw[2], h1[1])
	self:pack("chartName", gx[2], y1[2], gw[2], h1[2])
	self:pack("mods", gx[2], y1[3], gw[2], h1[3])

	local x1, w1 = gfx_util.layout(gx[2], gw[2], { -0.5, outerPanelsSize, 300, outerPanelsSize, -0.5 })
	local y2, h2 = gfx_util.layout(y1[5], h1[5], { -0.1, -0.45, -0.2, -0.15 })

	self:pack("scoringStats", x1[2], y1[5], w1[2], h1[5])
	self:pack("accuracy", x1[2], y2[1], w1[2], h2[1])
	self:pack("judgements", x1[2], y2[2], w1[2], h2[2])
	self:pack("grade", x1[2], y2[3], w1[2], h2[3])
	self:pack("timings", x1[2], y2[4], w1[2], h2[4])
end

return _Layout
