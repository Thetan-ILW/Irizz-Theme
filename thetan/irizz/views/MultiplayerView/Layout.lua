local gfx_util = require("gfx_util")

local Layout = require("sphere.views.Layout")

local Theme = require("thetan.irizz.views.Theme")

local _Layout = Layout()

local outerPanelsSize = 350
local innerPanelSize = 400
local gap = 20
local verticalPanelGap = 30
local horizontalPanelGap = 30

function _Layout:_footer(x, y, w, h)
	local x1, w1 = gfx_util.layout(x, w, { -0.65, -0.35 })
	self:pack("footerTitle", x1[1], y, w1[1], h)
	self:pack("footerChartName", x1[2], y, w1[2], h)
end

function _Layout:draw()
	local width, height = love.graphics.getDimensions()

	love.graphics.replaceTransform(gfx_util.transform(self.transform))

	local _x, _y = love.graphics.inverseTransformPoint(0, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width, height)

	local gx, gw = gfx_util.layout(_x, _xw, { gap, "*", gap })
	local gy, gh = gfx_util.layout(_y, _yh, { 64, -1, gap })

	local y1, h1 = gfx_util.layout(gy[2], gh[2], { gap, -0.1, gap, -0.9, gap, 20, gap })

	self:_footer(gx[2], y1[6], gw[2], h1[6])

	local x2, w2 = gfx_util.layout(
		gx[2],
		gw[2],
		{ -0.5, outerPanelsSize, horizontalPanelGap, innerPanelSize, horizontalPanelGap, outerPanelsSize, -0.5 }
	)

	self:pack("column1", x2[2], y1[4], w2[2], h1[4])
	self:pack("column2", x2[4], y1[4], w2[4], h1[4])
	self:pack("column3", x2[6], y1[4], w2[6], h1[4])
end

return _Layout
