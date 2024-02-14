local utf8 = require("utf8")
local just = require("just")
local theme = require("imgui.theme")

local Theme = require("thetan.iris.views.Theme")
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

	love.graphics.setColor(1, 1, 1, 1)

	local clipw = w - 10
	just.clip(love.graphics.rectangle, "fill", 0, 0, clipw, lh)

	local textHeight = font:getHeight()
	Theme:panel(w, textHeight)
	Theme:border(w, textHeight)
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

		love.graphics.printf(drawableText, 0, 0, w, "center")
		local offset = just.text(right)
		just.indent(-offset)
	else
		love.graphics.setColor(Color.unfocusedText)

		local drawableText = text

		if password then
			drawableText = string.rep("*", #text)
		end

		love.graphics.printf(drawableText, 0, 0, w, "center")
	end

	if not changed and text == "" then
		love.graphics.setColor(1, 1, 1, 0.5)
		love.graphics.printf(placeholder, 0, 0, w, "center")
	end

	just.clip()
	just.pop()
	just.next(w, textHeight + cfg.nextItemOffset)

	return changed, text, index
end
