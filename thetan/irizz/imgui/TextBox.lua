local just = require("just")
local gyatt = require("thetan.gyatt")

local colors = require("thetan.irizz.ui.colors")

local rounding = 8
local next_item_offset = 15

return function(id, text, index, w, h, password)
	local placeholder = ""
	if type(text) == "table" then
		text, placeholder = unpack(text)
	end
	text = tostring(text)

	local font = love.graphics.getFont()
	local lh = font:getHeight() * font:getLineHeight()
	h = h or lh

	local changed, active, hovered = just.button(id, just.is_over(w, h))
	if changed then
		just.focus(id)
	end

	just.push()
	just.origin()
	just.row(true)

	love.graphics.setColor(colors.ui.uiPanel)
	love.graphics.rectangle("fill", 0, 0, w, h, rounding, rounding)

	love.graphics.setColor(colors.ui.uiFrames)
	if just.focused_id == id then
		love.graphics.setColor(colors.ui.accent)
	end

	love.graphics.rectangle("line", 0, 0, w, h, rounding, rounding)

	local clipw = w - 10
	just.clip(love.graphics.rectangle, "fill", 0, 0, clipw, lh)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.translate(math.min(clipw - font:getWidth(text), 0), 0)

	local changed, left, right
	if just.focused_id == id then
		if just.keypressed("escape") then
			just.focus()
		end
		changed, text, index, left, right = just.textinput(text, index)
		love.graphics.setColor(colors.ui.text)

		local drawableText = text

		if password then
			drawableText = string.rep("*", #text)
		end

		gyatt.frame(drawableText, 0, -3, w, h, "center", "center")
		local offset = just.text(right)
		just.indent(-offset)
	else
		love.graphics.setColor(colors.ui.unfocusedText)

		local drawableText = text

		if password then
			drawableText = string.rep("*", #text)
		end

		gyatt.frame(drawableText, 0, -3, w, h, "center", "center")
	end

	if not changed and text == "" then
		love.graphics.setColor(1, 1, 1, 0.5)
		gyatt.frame(placeholder, 0, -3, w, h, "center", "center")
	end

	just.clip()
	just.pop()
	just.next(w, h + next_item_offset)

	return changed, text, index
end
