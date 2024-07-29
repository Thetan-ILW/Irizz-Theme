local just = require("just")
local gyatt = require("thetan.gyatt")
local map = require("math_util").map

local colors = require("thetan.irizz.ui.colors")

local rounding = 8
local size = 50
local size4 = size / 4
local size2 = size / 2

---@param w number
---@param h number
---@return number
local function getPosition(w, h)
	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local value = map(x, h / 2, w - h / 2, 0, 1)
	return math.min(math.max(value, 0), 1)
end

return function(id, value, w, h, displayValue)
	local over = just.is_over(w, h)
	local pos = getPosition(w, h)

	local new_value, active, hovered = just.slider(id, over, pos, value)

	love.graphics.setColor(colors.ui.uiPanel)
	love.graphics.rectangle("fill", 0, 0, w, size, rounding, rounding)
	love.graphics.setColor(colors.ui.uiFrames)
	love.graphics.rectangle("line", 0, 0, w, size, rounding, rounding)

	local x = map(math.min(math.max(value, 0), 1), 0, 1, size2, w - size2)
	love.graphics.setColor(colors.ui.accent)
	love.graphics.rectangle("fill", size4, size4, x, size2, rounding / 2, rounding / 2)
	love.graphics.setColor(colors.ui.darkerAccent)
	love.graphics.rectangle("line", size4, size4, x, size2, rounding / 2, rounding / 2)
	love.graphics.setColor(colors.ui.uiFrames)
	love.graphics.rectangle("line", x - size4, size4, size2, size2, rounding / 2, rounding / 2)

	if displayValue then
		local width = love.graphics.getFont():getWidth(displayValue) * gyatt.getTextScale()
		local tx = (w - width) / 2
		if x >= w / 2 then
			love.graphics.setColor(colors.ui.darkText)
			tx = math.min(tx, x - size / 2 - width)
		else
			love.graphics.setColor(colors.ui.text)
			tx = math.max(tx, x + size / 2)
		end
		gyatt.frame(displayValue, tx, -3, w, size, "left", "center")
	end

	just.next(w + size / 10, size)

	return new_value
end
