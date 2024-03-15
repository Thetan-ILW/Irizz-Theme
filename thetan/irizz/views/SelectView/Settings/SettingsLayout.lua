local gfx_util = require("gfx_util")

local Layout = require("sphere.views.Layout")

local Theme = require("thetan.irizz.views.Theme")
local tabsPanelSize = Theme.layout.settingsTabsPanelSize
local mainPanelSize = Theme.layout.settingsMainPanelSize
local gap = Theme.layout.gap
local verticalPanelGap = Theme.layout.verticalPanelGap
local horizontalPanelGap = Theme.layout.horizontalPanelGap

local _Layout = Layout()

function _Layout:draw(offset)
    local width, height = love.graphics.getDimensions()

	love.graphics.replaceTransform(gfx_util.transform(self.transform))

	local position = width * offset

	local _x, _y = love.graphics.inverseTransformPoint(position, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width + position, height)

	local gx, gw = gfx_util.layout(_x, _xw, {20, "*", 20})
	local gy, gh = gfx_util.layout(_y, _yh , {64, "*", 20})

	local x1, w1 = gfx_util.layout(gx[2], gw[2], {-0.5, tabsPanelSize, horizontalPanelGap, mainPanelSize, horizontalPanelGap, tabsPanelSize, -0.5})
	local y1, h1 = gfx_util.layout(gy[2], gh[2], {gap, -0.1, gap, -0.9, gap, 20, gap})

	local y2, h2 = gfx_util.layout(y1[4], h1[4], {-0.2, -0.6, -0.2})

	self:pack("tabs", x1[2], y2[2], w1[2], h2[2])
	self:pack("settings", x1[4], y1[4], w1[4], h1[4])
end

return _Layout
