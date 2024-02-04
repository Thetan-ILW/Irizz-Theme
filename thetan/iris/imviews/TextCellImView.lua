local just = require("just")
local gfx_util = require("gfx_util")

return function(w, h, align, name, value, font1, font2)
	local limit = 2 * w
	local x = 0
	if align == "right" then
		x = -w
	elseif align == "center" then
		limit = w
	end

	love.graphics.setFont(font1)
	gfx_util.printBaseline(tostring(name), x, 19, limit, 1, align)
	love.graphics.setFont(font2)
	gfx_util.printBaseline(tostring(value or 0), x, 45, limit, 1, align)

	just.next(w, h)
end
