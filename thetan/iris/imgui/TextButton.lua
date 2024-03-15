local just = require("just")
local gfx_util = require("gfx_util")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local cfg = Theme.imgui

return function(id, text, w, h)
	local changed, active, hovered = just.button(id, just.is_over(w, cfg.size))

	love.graphics.setColor(hovered and Color.uiHover or Color.uiPanel)
	love.graphics.rectangle("fill", 0, 0 , w, cfg.size, cfg.rounding)
	love.graphics.setColor(Color.uiFrames)
	love.graphics.rectangle("line", 0, 0 , w, cfg.size, cfg.rounding)

	love.graphics.setColor(1, 1, 1, 1)
	gfx_util.printFrame(tostring(text), 0, 0, w, cfg.size, "center", "center")

	just.next(w, h + cfg.nextItemOffset)

	return changed
end
