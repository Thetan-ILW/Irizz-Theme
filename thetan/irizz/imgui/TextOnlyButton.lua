local just = require("just")
local gyatt = require("thetan.gyatt")

local colors = require("thetan.irizz.ui.colors")

return function(id, text, w, h, align, active)
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local over = 0 <= mx and mx <= w and 0 <= my and my <= h

	local changed, _, hovered = just.button(id, over)
	local color = hovered and colors.ui.buttonHover or colors.ui.button
	color = active and colors.ui.select or color
	love.graphics.setColor(color)
	love.graphics.rectangle("fill", 0, 2, w, h - 2)
	love.graphics.setColor(colors.ui.separator)
	love.graphics.rectangle("fill", w / 2 - w / 4, h - 2, w / 2, 4)

	local font = love.graphics.getFont()
	local fh = font:getHeight()
	local p = 0

	align = align or "center"
	if align ~= "center" then
		p = (h - fh) / 2
	end

	love.graphics.setColor(1, 1, 1, 1)
	gyatt.frame(text, p, 0, w - p * 2, h, align, "center")

	just.next(w, h)

	return changed
end
