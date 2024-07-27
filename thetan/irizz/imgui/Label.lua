local just = require("just")
local gyatt = require("thetan.gyatt")

return function(id, text, h)
	local font = love.graphics.getFont()
	local w = font:getWidth(text)

	just.mouse_over(id, just.is_over(w, h), "mouse")

	gyatt.frame(text, 0, 0, w, h, "left", "center")

	just.next(w, h)

	return w, h
end
