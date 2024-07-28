local just = require("just")
local gyatt = require("thetan.gyatt")

local Theme = require("thetan.irizz.views.Theme")
local colors = require("thetan.irizz.ui.colors")
local cfg = Theme.imgui

return function(id, w, v, text)
	local size = cfg.size
	w = w + size
	local size4 = size / 4
	local size2 = size / 2

	local changed, active, hovered = just.button(id, just.is_over(w, size))

	love.graphics.setColor(colors.ui.uiPanel)
	love.graphics.rectangle("fill", 0, 0, w, size, cfg.rounding, cfg.rounding)
	love.graphics.setColor(colors.ui.uiFrames)
	love.graphics.rectangle("line", 0, 0, w, size, cfg.rounding, cfg.rounding)

	if v then
		love.graphics.setColor(colors.ui.accent)
		love.graphics.rectangle("fill", size4, size4, w - size2, size2, cfg.rounding / 2, cfg.rounding / 2)
		love.graphics.setColor(colors.ui.darkerAccent)
		love.graphics.rectangle("line", size4, size4, w - size2, size2, cfg.rounding / 2, cfg.rounding / 2)
	end

	gyatt.frame(text, 0, 0, w, size, "center", "center")
	just.next(w + 10, size + cfg.nextItemOffset)
	return changed
end
