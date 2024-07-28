local gyatt = require("thetan.gyatt")
local colors = require("thetan.irizz.ui.colors")

local ui = {}

local gfx = love.graphics

local shadow_offset = 3

function ui:frameWithShadow(text, x, y, w, h, ax, ay)
	local r, g, b, a = gfx.getColor()

	gfx.setColor(colors.ui.textShadow)
	gyatt.frame(text, x + shadow_offset, y + shadow_offset, w, h, ax, ay)
	gfx.setColor({ r, g, b, a })
	gyatt.frame(text, x, y, w, h, ax, ay)
end

function ui:panel(w, h)
	love.graphics.setColor(colors.ui.panel)
	love.graphics.rectangle("fill", 0, 0, w, h, 8, 8)
end

local line_width = 4
local half = line_width / 2
function ui:border(w, h)
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(line_width)
	love.graphics.setColor(colors.ui.border)
	love.graphics.rectangle("line", -half, -half, w + line_width, h + line_width, 8, 8)
end

return ui
