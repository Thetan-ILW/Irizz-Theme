local gfx_util = require("gfx_util")

local Layout = require("sphere.views.Layout")

local _Layout = Layout()

local Theme = require("thetan.irizz.views.Theme")
local outerPanelsSize = Theme.layout.outerPanelsSize
local innerPanelSize = Theme.layout.innerPanelSize
local gap = Theme.layout.gap
local verticalPanelGap = Theme.layout.verticalPanelGap
local horizontalPanelGap = Theme.layout.horizontalPanelGap

function _Layout:_footer(x, y, w, h)
	local x1, w1 = gfx_util.layout(x, w, {-0.65, -0.35})
	self:pack("footerTitle", x1[1], y, w1[1], h)
	self:pack("footerChartName", x1[2], y, w1[2], h)
end

function _Layout:_difficultyAndInfo(x, y, w, h)
	local x1, w1 = gfx_util.layout(x, w, {-0.3, -0.7})
	local y1, h1 = gfx_util.layout(y, h, {-0.3, 4, -0.7})

	self:pack("difficulty", x1[1], y1[1], w1[1], h1[1])
	self:pack("patterns", x1[2], y1[1], w1[2], h1[1])
	self:pack("difficultyAndInfoLine", x, y1[2], w, h1[2])
	self:pack("info1", x, y1[3], w, h1[3])

	local y2, h2 = gfx_util.layout(y1[3], h1[3], {-1/3,-1/3,-1/3})
	self:pack("info1row1", x, y2[1], w, h2[1])
	self:pack("info1row2", x, y2[2], w, h2[2])
	self:pack("info1row3", x, y2[3], w, h2[3])
end

function _Layout:_modsAndInfo(x, y, w, h)
	local x1, w1 = gfx_util.layout(x, w, {-0.7, -0.3})
	local y1, h1 = gfx_util.layout(y, h, {-0.7, 4, -0.3})

	self:pack("timeRate", x1[2], y1[3], w1[2], h1[3])
	self:pack("mods", x1[1], y1[3], w1[1], h1[3])
	self:pack("modsAndInfoLine", x, y1[2], w, h1[2])
	self:pack("info2", x, y1[1], w, h1[1])

	local y2, h2 = gfx_util.layout(y1[1], h1[1], {-1/3,-1/3,-1/3})
	self:pack("info2row1", x, y2[1], w, h2[1])
	self:pack("info2row2", x, y2[2], w, h2[2])
	self:pack("info2row3", x, y2[3], w, h2[3])
end

function _Layout:draw(offset)
    local width, height = love.graphics.getDimensions()

	love.graphics.replaceTransform(gfx_util.transform(self.transform))

	local position = width * offset

	local _x, _y = love.graphics.inverseTransformPoint(position, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width + position, height)

	local _w, _h = _xw - _x, _yh - _y
	self:pack("background", _x, _y, _w, _h)

	local gx, gw = gfx_util.layout(_x, _xw, {gap, "*", gap})
	local gy, gh = gfx_util.layout(_y, _yh, {64, -1, gap})

	local y1, h1 = gfx_util.layout(gy[2], gh[2], {gap, -0.1, gap, -0.9, gap, 20, gap})

	self:_footer(gx[2], y1[6], gw[2], h1[6])
	self:pack("search", gx[2], y1[2], gw[2], h1[2])

	local x2, w2 = gfx_util.layout(gx[2], gw[2], {-0.5, outerPanelsSize, horizontalPanelGap, innerPanelSize, horizontalPanelGap, outerPanelsSize, -0.5})
	self:pack("column1", x2[2], y1[4], w2[2], h1[4])
	self:pack("column2", x2[4], y1[4], w2[4], h1[4])
	self:pack("column3", x2[6], y1[4], w2[6], h1[4])

	local y2, h2 = gfx_util.layout(y1[4], h1[4], {-0.15, gap, -0.55, verticalPanelGap, -0.3})
	local y3, h3 = gfx_util.layout(y1[4], h1[4], {-0.3, verticalPanelGap, -0.55, -0.15})

	local x3, w3 = gfx_util.layout(x2[2], w2[2], {-0.2, -0.8})
	local x4, w4 = gfx_util.layout(x2[6], w2[6], {-0.8, -0.2})

	self:pack("scoreFilters", x2[2], y2[1], w2[2], h2[1])
	self:pack("scores", x2[2], y2[3], w2[2], h2[3])
	self:pack("infoAndMods", x3[2], y2[5], w3[2], h2[5])
	self:pack("difficultyAndInfo", x4[1], y3[1], w4[1], h3[1])
	self:pack("charts", x2[6], y3[3], w2[6], h3[3])

	self:_difficultyAndInfo(x4[1], y3[1], w4[1], h3[1])
	self:_modsAndInfo(x3[2], y2[5], w3[2], h2[5])
end

return _Layout
