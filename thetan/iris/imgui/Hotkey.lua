local just = require("just")
local gfx_util = require("gfx_util")
local theme = require("imgui.theme")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local cfg = Theme.imgui.hotkey

return function(id, device, key, w, h)
	local _key = key
	local changed = false

	if just.focused_id == id then
		local k = just.next_input(device == "keyboard" and "key" or device, "pressed")
		if k then
			key = k
			changed = true
			just.focus()
		end
		if just.keypressed("escape", true) then
			changed = true
			key = nil
			just.focus()
		end
	end

	local _changed, active, hovered = just.button(id, just.is_over(w, h))
	if _changed then
		just.focus(id)
		active = true
	end

	love.graphics.setColor(just.focused_id == id and Color.uiActive or Color.uiPanel)
	love.graphics.rectangle("fill", 0, 0, w, cfg.size, cfg.rounding)
	love.graphics.setColor(Color.uiFrames)
	love.graphics.rectangle("line", 0, 0, w, cfg.size, cfg.rounding)

	love.graphics.setColor(1, 1, 1, 1)

	local text = just.focused_id == id and "???" or key or "none"
	gfx_util.printFrame(text, h * theme.padding, 0, w, h, "left", "center")

	just.next(w + cfg.size/10, h + cfg.nextItemOffset)

	return changed, key
end
