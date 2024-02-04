local gfx_util = require("gfx_util")

local Layout = require("sphere.views.Layout")

local _Layout = Layout()

local gap = 20
local header_height = 42

function _Layout:header(x, y, w, h)
    self:pack("headerBody", x, y, w, h)

    local x1, w1 = gfx_util.layout(x, w, {-1/3, -1/3, -1/3})
    self:pack("headerButtons", x1[1], y, w1[1], h)
  
    self:pack("buttons", x1[1], y, w1[1], h)
    self:pack("user", x1[3], y, w1[3], h)
end

function _Layout:draw()
    local width, height = love.graphics.getDimensions()

	love.graphics.replaceTransform(gfx_util.transform(self.transform))

	local _x, _y = love.graphics.inverseTransformPoint(0, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width, height)

	local _w, _h = _xw - _x, _yh - _y

    self:pack("background", _x, _y, _w, _h)

    local x1, w1 = gfx_util.layout(_x, _xw, {gap, "*", gap})
    local y1, h1 = gfx_util.layout(_y, _yh, {gap, header_height, "*"})
    self:header(x1[2], y1[2], w1[2], h1[2])
end

return _Layout