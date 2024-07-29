local just = require("just")
local gyatt = require("thetan.gyatt")

local colors = require("thetan.irizz.ui.colors")

local rounding = 8
local size = 50
local next_item_offset = 15

return function(id, text, w, h)
	local changed, active, hovered = just.button(id, just.is_over(w, size))

	love.graphics.setColor(hovered and colors.ui.uiHover or colors.ui.uiPanel)
	love.graphics.rectangle("fill", 0, 0, w, size, rounding)
	love.graphics.setColor(colors.ui.uiFrames)
	love.graphics.rectangle("line", 0, 0, w, size, rounding)

	love.graphics.setColor(colors.ui.text)
	gyatt.frame(tostring(text), 0, 0, w, size, "center", "center")

	just.next(w, h + next_item_offset)

	return changed
end
