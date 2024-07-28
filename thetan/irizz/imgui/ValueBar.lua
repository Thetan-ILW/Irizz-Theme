local just = require("just")
local gfx_util = require("gfx_util")

local colors = require("thetan.irizz.ui.colors")

---@param text any
---@param x number
---@param y number
---@param w number
---@param h number
local function _print(text, x, y, w, h)
	gfx_util.printFrame(tostring(text), x, y, w, h, "center", "center")
end

---@param w number
---@param h number
---@param ratio number
---@param name string
---@param value any
---@param right boolean?
local function print_values(w, h, ratio, name, value, right)
	local font = love.graphics.getFont()
	local nw = font:getWidth(name) + 20
	local vw = font:getWidth(value) + 20
	local fw = nw + vw
	local offset = vw > w * (1 - ratio) and vw or 0

	local x = 0
	local a = 1
	local b = 0
	if right then
		x = w
		a = -1
		b = -1
	end

	love.graphics.translate(x, 0)
	if fw > w then
		love.graphics.setColor(colors.ui.darkText)
		_print(name, b * nw, 0, nw, h)
		love.graphics.settColor(colors.ui.text)
		_print(value, a * nw + b * vw, 0, vw, h)
	elseif fw > w * (1 - ratio) or nw <= w * ratio then
		love.graphics.setColor(colors.ui.darkText)
		_print(name, b * nw, 0, nw, h)
		love.graphics.setColor(colors.ui.darkText)
		_print(value, a * math.max(nw, w * ratio - offset) + b * vw, 0, vw, h)
	else
		love.graphics.setColor(colors.ui.text)
		_print(name, a * w * ratio + b * nw, 0, nw, h)
		_print(value, a * (nw + w * ratio) + b * vw, 0, vw, h)
	end
	love.graphics.translate(-x, 0)
end

local shadow = 2
return function(w, h, ratio, name, value, right)
	love.graphics.setColor(colors.ui.uiPanel)
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setColor(colors.ui.accent)
	love.graphics.rectangle("fill", right and w * (1 - ratio) or 0, 0, w * ratio, h)

	print_values(w, h, ratio, name, value, right)

	just.next(w, h)
end
