local just = require("just")
local gyatt = require("thetan.gyatt")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local cfg = Theme.imgui

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

	h = cfg.size
	love.graphics.setColor(Color.uiPanel)
	love.graphics.rectangle("fill", 0, 0, w, h, cfg.rounding, cfg.rounding)

	love.graphics.setColor(Color.uiFrames)
	if just.focused_id == id then
		love.graphics.setColor(Color.accent)
	end

	love.graphics.rectangle("line", 0, 0, w, h, cfg.rounding, cfg.rounding)

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
		love.graphics.setColor(Color.text)

		local drawableText = text

		if password then
			drawableText = string.rep("*", #text)
		end

		gyatt.frame(drawableText, 0, -3, w, h, "center", "center")
		local offset = just.text(right)
		just.indent(-offset)
	else
		love.graphics.setColor(Color.unfocusedText)

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
	just.next(w, h + cfg.nextItemOffset)

	return changed, text, index
end
