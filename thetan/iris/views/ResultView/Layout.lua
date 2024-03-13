local gfx_util = require("gfx_util")

local Layout = require("sphere.views.Layout")

local _Layout = Layout()

local Theme = require("thetan.iris.views.Theme")
local outerPanelsSize = Theme.layout.outerPanelsSize
local innerPanelSize = 300 
local gap = Theme.layout.gap
local verticalPanelGap = 4
local horizontalPanelGap = 4

function _Layout:_footer(x, y, w, h)
	local x1, w1 = gfx_util.layout(x, w, { -0.65, -0.35 })
	self:pack("footerTitle", x1[1], y, w1[1], h)
	self:pack("footerChartName", x1[2], y, w1[2], h)
end

function _Layout:_difficulty(x, y, w, h)
	local x1, w1 = gfx_util.layout(x, w, { -0.25, -0.75 })

	self:pack("difficulty", x1[1], y, w1[1], h)
	self:pack("patterns", x1[2], y, w1[2], h)
	self:pack("difficultyLine", x, y, w, h)
end

function _Layout:draw()
	local width, height = love.graphics.getDimensions()

	love.graphics.replaceTransform(gfx_util.transform(self.transform))

	local _x, _y = love.graphics.inverseTransformPoint(0, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width, height)

	local gx, gw = gfx_util.layout(_x, _xw, { gap, "*", gap })
	local gy, gh = gfx_util.layout(_y, _yh, { 64, -1, gap })

	local _w, _h = _xw - _x, _yh - _y
	self:pack("background", _x, _y, _w, _h)
	local gx2, gw2 = gfx_util.layout(gx[2], gw[2], {-0.5, outerPanelsSize + horizontalPanelGap + innerPanelSize + horizontalPanelGap + outerPanelsSize, -0.5})
	local x1, w1 = gfx_util.layout(gx2[2], gw2[2],
		{50, -1/3, horizontalPanelGap, -1/3, horizontalPanelGap, -1/3, 50})
	local y1, h1 = gfx_util.layout(gy[2], gh[2], { gap, -0.2, gap, -0.6, -0.2, gap, 20, gap })
	self:_footer(gx[2], y1[7], gw[2], h1[7])

	local y3, h3 = gfx_util.layout(y1[4], h1[4],
		{ -0.3, 1, -0.55, verticalPanelGap, -0.15 })

	self:pack("hitGraph", gx2[2], y3[1], gw2[2], h3[1])

	local panelWidth = w1[2] + w1[3] + w1[4] + w1[5] + w1[6]
	local panelHeight = h3[2] + h3[3] + h3[4] + h3[5]
	self:pack("panel", x1[2], y3[2], panelWidth, panelHeight)

	self:pack("line1", x1[3], y3[2], w1[3], panelHeight)
	self:pack("line2", x1[5], y3[2], w1[5], panelHeight)
	self:pack("line3", x1[2], y3[4], w1[2], h3[4])
	self:pack("line4", x1[4], y3[4], w1[4], h3[4])
	self:pack("line5", x1[6], y3[4], w1[6], h3[4])

	self:pack("judgements", x1[2], y3[3], w1[2], h3[3])
	self:pack("judgementsAccuracy", x1[2], y3[5], w1[2], h3[5])
	self:pack("normalscore", x1[4], y3[3], w1[4], h3[3])
	self:pack("scores", x1[6], y3[3], w1[6], h3[3])
	self:_difficulty(x1[4], y3[5], w1[4], h3[5])
	self:pack("pauses", x1[6], y3[5], w1[6], h3[5])
	self:pack("mods", gx[2], y1[2], gw[2], h1[2])
end

return _Layout
