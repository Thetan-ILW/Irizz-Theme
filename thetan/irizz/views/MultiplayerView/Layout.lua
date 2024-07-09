local gfx_util = require("gfx_util")

local Layout = require("sphere.views.Layout")

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

	local y1, h1 = gfx_util.layout(gy[2], gh[2], { gap, -0.1, gap, -0.9, gap, 30 })

	self:pack("roomInfo", gx[2], y1[2], gw[2], h1[2])
	self:_footer(gx[2], y1[6], gw[2], h1[6])

	local x1, w1 = gfx_util.layout(
		gx[2],
		gw[2],
		{ -0.5, outerPanelsSize, horizontalPanelGap, innerPanelSize, horizontalPanelGap, outerPanelsSize, -0.5 }
	)

	local x2, w2 = gfx_util.layout(gx[2], gw[2], { -0.5, 750, -0.5 })

	local y2, h2 = gfx_util.layout(y1[4], h1[4], { -0.5, verticalPanelGap, -0.5 })

	self:pack("playerList", x1[2], y2[1], w1[2], h2[1])
	self:pack("buttons", x1[6], y2[1], w1[6], h2[1])
	self:pack("chat", x2[2], y2[3], w2[2], h2[3])

	local dx, dw = gfx_util.layout(x1[4], w1[4], { 100, -1 })
	local dy, dh = gfx_util.layout(y2[1], h2[1], { -0.25, verticalPanelGap, -0.75 })
	self:pack("difficulty", x1[4], dy[1], w1[4], dh[1])
	self:pack("difficultyValue", dx[1], dy[1], dw[1], dh[1])
	self:pack("difficultyPatterns", dx[2], dy[1], dw[2], dh[1])
	self:pack("info", x1[4], dy[3], w1[4], dh[3])
end

return _Layout
