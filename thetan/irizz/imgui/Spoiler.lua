local just = require("just")
local gyatt = require("thetan.gyatt")

local height = 0
local height_start = 0
local base_height = 0
local width = 0
local open_frame_id

local rounding = 8
local size = 50
local next_item_offset = 15

local colors = require("thetan.irizz.ui.colors")

return function(id, w, h, preview)
	if id then
		base_height = h
		width = w

		local changed, active, hovered = just.button(id, just.is_over(w, h))

		if just.focused_id ~= id and changed then
			just.focus(id)
			open_frame_id = id
		end
		if just.focused_id ~= id or open_frame_id == id then
			love.graphics.setColor(colors.ui.uiPanel)
			love.graphics.rectangle("fill", 0, 0, w, size, rounding, rounding)
			love.graphics.setColor(colors.ui.uiFrames)
			love.graphics.rectangle("line", 0, 0, w, size, rounding, rounding)
			love.graphics.polygon("line", w - 20, h / 4, w - 30, h / 1.6, w - 40, h / 4)

			love.graphics.setColor(colors.ui.text)
			gyatt.frame(tostring(preview), 0, -2, w, size, "center", "center")

			if open_frame_id == id then
				just.clip(love.graphics.rectangle, "fill", 0, 0, 0, 0)
				return true
			end
			just.next(w + size / 10, h + next_item_offset)
			return
		end

		height_start = just.height

		love.graphics.setColor(1, 1, 1, 1)

		just.clip(love.graphics.rectangle, "fill", 0, 0, w, height, rounding)

		local over = just.is_over(width, height)
		just.container(id, over)
		just.mouse_over(id, over, "mouse")

		return true
	end

	height = just.height - height_start
	just.container()
	just.clip()

	h = base_height
	if open_frame_id then
		just.next(width + size / 10, h + next_item_offset)
		open_frame_id = nil
		return
	end

	love.graphics.setColor(colors.ui.accent)
	love.graphics.rectangle("line", 0, 0, w, height, rounding)

	just.next(width + size / 10, height + next_item_offset)
end
