local just = require("just")
local colors = require("thetan.irizz.ui.colors")

local size = 50
local size4 = size / 4
local size2 = size / 2
local rounding = 8

return function(id, v)
	local changed, active, hovered = just.button(id, just.is_over(size, size))

	love.graphics.setColor(colors.ui.uiPanel)
	love.graphics.rectangle("fill", 0, 0, size, size, rounding, rounding)
	love.graphics.setColor(colors.ui.uiFrames)
	love.graphics.rectangle("line", 0, 0, size, size, rounding, rounding)

	if v then
		love.graphics.setColor(colors.ui.accent)
		love.graphics.rectangle("fill", size4, size4, size2, size2, rounding / 2, rounding / 2)
		love.graphics.setColor(colors.ui.darkerAccent)
		love.graphics.rectangle("line", size4, size4, size2, size2, rounding / 2, rounding / 2)
	end

	just.next(size + size / 10, size)
	return changed
end
