local gfx_util = require("gfx_util")

local Layout = require("sphere.views.Layout")

local _Layout = Layout()

local outerPanelsSize = 350
local innerPanelSize = 400
local gap = 20
local verticalPanelGap = 30
local horizontalPanelGap = 30
local buttonsPanelScale = 0.7

function _Layout:_footer(x, y, w, h)
	local x1, w1 = gfx_util.layout(x, w, { -0.65, -0.35 })
	self:pack("name", x1[1], y, w1[1], h)
	self:pack("mode", x1[2], y, w1[2], h)
end

function _Layout:_queue(x, y, w, h)
	local y1, h1 = gfx_util.layout(y, h, { -0.1, -0.8, -0.1 })
	self:pack("queue", x, y1[2], w, h1[2])
end

function _Layout:_rightPanels(x, y, w, h)
	local x1, w1 = gfx_util.layout(x, w, { -buttonsPanelScale, -1 + buttonsPanelScale })
	local y1, h1 = gfx_util.layout(y, h, { -0.15, -0.2, verticalPanelGap, -0.5, -0.15 })
	self:pack("buttons", x1[1], y1[2], w1[1], h1[2])
	self:pack("charts", x, y1[4], w, h1[4])

	local y2, h2 = gfx_util.layout(y1[2], h1[2], { -1 / 3, -1 / 3, -1 / 3 })
	self:pack("button1", x1[1], y2[1], w1[1], h2[1])
	self:pack("button2", x1[1], y2[2], w1[1], h2[2])
	self:pack("button3", x1[1], y2[3], w1[1], h2[3])
end

function _Layout:draw(offset)
	local width, height = love.graphics.getDimensions()

	love.graphics.replaceTransform(gfx_util.transform(self.transform))

	local position = width * offset

	local _x, _y = love.graphics.inverseTransformPoint(position, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width + position, height)

	local gx, gw = gfx_util.layout(_x, _xw, { 20, "*", 20 })
	local gy, gh = gfx_util.layout(_y, _yh, { 64, "*", 20 })

	local x1, w1 = gfx_util.layout(
		gx[2],
		gw[2],
		{ -0.5, outerPanelsSize, horizontalPanelGap, innerPanelSize, horizontalPanelGap, outerPanelsSize, -0.5 }
	)
	local y1, h1 = gfx_util.layout(gy[2], gh[2], { gap, -0.1, gap, -0.9, gap, 20, gap })

	self:pack("searchField", gx[2], y1[2], gw[2], h1[2])
	self:pack("list", x1[4], y1[4], w1[4], h1[4])
	self:_footer(gx[2], y1[6], gw[2], h1[6])
	self:_queue(x1[2], y1[4], w1[2], h1[4])
	self:_rightPanels(x1[6], y1[4], w1[6], h1[4])
end

return _Layout
