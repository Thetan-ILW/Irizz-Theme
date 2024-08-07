local just = require("just")
local gyatt = require("thetan.gyatt")
local theme = require("imgui.theme")

local colors = require("thetan.irizz.ui.colors")

local size = 50
local rounding = 8
local next_item_offset = 15

return function(id, text, w, h)
	local changed = false
	local key, device, device_id = text, nil, nil

	if just.focused_id == id then
		local k, dev, dev_id = just.next_input("pressed")
		if k then
			key, device, device_id = k, dev, dev_id
			changed = true
			just.focus()
		end
		if just.keypressed("escape", true) then
			changed = true
			key, device, device_id = nil, nil, nil
			just.focus()
		end
	end

	local _changed, active, hovered = just.button(id, just.is_over(w, h))

	if _changed then
		just.focus(id)
	end

	local ctrlDown = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")

	if _changed and ctrlDown then
		key, device, device_id = nil, nil, nil
		changed = true
		just.focus()
	end

	love.graphics.setColor(just.focused_id == id and colors.ui.uiActive or colors.ui.uiPanel)
	love.graphics.rectangle("fill", 0, 0, w, h, rounding)
	love.graphics.setColor(colors.ui.uiFrames)
	love.graphics.rectangle("line", 0, 0, w, h, rounding)

	love.graphics.setColor(1, 1, 1, 1)

	text = just.focused_id == id and "???" or text or ""
	gyatt.frame(text, h * theme.padding, 0, w, h, "left", "center")

	just.next(w + h / 10, h + next_item_offset)

	return changed, key, device, device_id
end
