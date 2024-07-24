local gyatt = require("thetan.gyatt")

local ui = {}

local gfx = love.graphics

function ui:setColors(colors)
	self.colors = colors
end

local shadow_offset = 3

function ui:frameWithShadow(text, x, y, w, h, ax, ay)
	local r, g, b, a = gfx.getColor()
	gfx.setColor(self.colors.textShadow)
	gyatt.frame(text, x + shadow_offset, y + shadow_offset, w, h, ax, ay)
	gfx.setColor({ r, g, b, a })
	gyatt.frame(text, x, y, w, h, ax, ay)
end

return ui
