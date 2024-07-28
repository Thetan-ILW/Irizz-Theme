local just = require("just")
local Theme = require("thetan.irizz.views.Theme")
local colors = require("thetan.irizz.ui.colors")
local cfg = Theme.imgui

return function(id, v, size)
	size = cfg.size
	local size4 = size / 4
	local size2 = size / 2

	local changed, active, hovered = just.button(id, just.is_over(size, size))

	love.graphics.setColor(colors.ui.uiPanel)
	love.graphics.rectangle("fill", 0, 0, size, size, cfg.rounding, cfg.rounding)
	love.graphics.setColor(colors.ui.uiFrames)
	love.graphics.rectangle("line", 0, 0, size, size, cfg.rounding, cfg.rounding)

	if v then
		love.graphics.setColor(colors.ui.accent)
		love.graphics.rectangle("fill", size4, size4, size2, size2, cfg.rounding / 2, cfg.rounding / 2)
		love.graphics.setColor(colors.ui.darkerAccent)
		love.graphics.rectangle("line", size4, size4, size2, size2, cfg.rounding / 2, cfg.rounding / 2)
	end

	just.next(size + size / 10, size)
	return changed
end
