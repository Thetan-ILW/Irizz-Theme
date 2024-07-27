local just = require("just")
local gyatt = require("thetan.gyatt")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local cfg = Theme.imgui

return function(id, text, w, h)
	local changed, active, hovered = just.button(id, just.is_over(w, cfg.size))

	love.graphics.setColor(hovered and Color.uiHover or Color.uiPanel)
	love.graphics.rectangle("fill", 0, 0, w, cfg.size, cfg.rounding)
	love.graphics.setColor(Color.uiFrames)
	love.graphics.rectangle("line", 0, 0, w, cfg.size, cfg.rounding)

	love.graphics.setColor(Color.text)
	gyatt.frame(tostring(text), 0, 0, w, cfg.size, "center", "center")

	if changed then
		Theme:playSound("buttonClick")
	end

	just.next(w, h + cfg.nextItemOffset)

	return changed
end
